#include "core/convar/convar.h"
#include "engine/r2engine.h"
#include "shared/exploit_fixes/ns_limits.h"
#include "masterserver/masterserver.h"

#include <string>
#include <thread>
#include <bcrypt.h>

AUTOHOOK_INIT()

static ConVar* Cvar_net_debug_atlas_packet;
static ConVar* Cvar_net_debug_atlas_packet_insecure;

static BCRYPT_ALG_HANDLE HMACSHA256;
constexpr size_t HMACSHA256_LEN = 256 / 8;

static bool InitHMACSHA256()
{
	NTSTATUS status;
	DWORD hashLength = 0;
	ULONG hashLengthSz = 0;

	if ((status = BCryptOpenAlgorithmProvider(&HMACSHA256, BCRYPT_SHA256_ALGORITHM, NULL, BCRYPT_ALG_HANDLE_HMAC_FLAG)))
	{
		spdlog::error("failed to initialize HMAC-SHA256: BCryptOpenAlgorithmProvider: error 0x{:08X}", (ULONG)status);
		return false;
	}

	if ((status = BCryptGetProperty(HMACSHA256, BCRYPT_HASH_LENGTH, (PUCHAR)&hashLength, sizeof(hashLength), &hashLengthSz, 0)))
	{
		spdlog::error("failed to initialize HMAC-SHA256: BCryptGetProperty(BCRYPT_HASH_LENGTH): error 0x{:08X}", (ULONG)status);
		return false;
	}

	if (hashLength != HMACSHA256_LEN)
	{
		spdlog::error("failed to initialize HMAC-SHA256: BCryptGetProperty(BCRYPT_HASH_LENGTH): unexpected value {}", hashLength);
		return false;
	}

	return true;
}

// compare the HMAC-SHA256(data, key) against sig (note: all strings are treated as raw binary data)
static bool VerifyHMACSHA256(std::string key, std::string sig, std::string data)
{
	uint8_t invalid = 1;
	char hash[HMACSHA256_LEN];

	NTSTATUS status;
	BCRYPT_HASH_HANDLE h = NULL;

	if ((status = BCryptCreateHash(HMACSHA256, &h, NULL, 0, (PUCHAR)key.c_str(), (ULONG)key.length(), 0)))
	{
		spdlog::error("failed to verify HMAC-SHA256: BCryptCreateHash: error 0x{:08X}", (ULONG)status);
		goto cleanup;
	}

	if ((status = BCryptHashData(h, (PUCHAR)data.c_str(), (ULONG)data.length(), 0)))
	{
		spdlog::error("failed to verify HMAC-SHA256: BCryptHashData: error 0x{:08X}", (ULONG)status);
		goto cleanup;
	}

	if ((status = BCryptFinishHash(h, (PUCHAR)&hash, (ULONG)sizeof(hash), 0)))
	{
		spdlog::error("failed to verify HMAC-SHA256: BCryptFinishHash: error 0x{:08X}", (ULONG)status);
		goto cleanup;
	}

	// constant-time compare
	if (sig.length() == sizeof(hash))
	{
		invalid = 0;
		for (size_t i = 0; i < sizeof(hash); i++)
			invalid |= (uint8_t)(sig[i]) ^ (uint8_t)(hash[i]);
	}

cleanup:
	if (h)
		BCryptDestroyHash(h);
	return !invalid;
}

// v1 HMACSHA256-signed masterserver request (HMAC-SHA256(JSONData, MasterServerToken) + JSONData)
static void ProcessAtlasConnectionlessPacketSigreq1(R2::netpacket_t* packet, bool dbg, std::string pType, std::string pData)
{
	if (pData.length() < HMACSHA256_LEN)
	{
		if (dbg)
			spdlog::warn("ignoring Atlas connectionless packet (size={} type={}): invalid: too short for signature", packet->size, pType);
		return;
	}

	std::string pSig; // is binary data, not actually an ASCII string
	pSig = pData.substr(0, HMACSHA256_LEN);
	pData = pData.substr(HMACSHA256_LEN);

	if (!g_pMasterServerManager || !g_pMasterServerManager->m_sOwnServerAuthToken[0])
	{
		if (dbg)
			spdlog::warn(
				"ignoring Atlas connectionless packet (size={} type={}): invalid (data={}): no masterserver token yet",
				packet->size,
				pType,
				pData);
		return;
	}

	if (!VerifyHMACSHA256(std::string(g_pMasterServerManager->m_sOwnServerAuthToken), pSig, pData))
	{
		if (!Cvar_net_debug_atlas_packet_insecure->GetBool())
		{
			if (dbg)
				spdlog::warn(
					"ignoring Atlas connectionless packet (size={} type={}): invalid: invalid signature (key={})",
					packet->size,
					pType,
					std::string(g_pMasterServerManager->m_sOwnServerAuthToken));
			return;
		}
		spdlog::warn(
			"processing Atlas connectionless packet (size={} type={}) with invalid signature due to net_debug_atlas_packet_insecure",
			packet->size,
			pType);
	}

	if (dbg)
		spdlog::info("got Atlas connectionless packet (size={} type={} data={})", packet->size, pType, pData);

	std::thread t(&MasterServerManager::ProcessConnectionlessPacketSigreq1, g_pMasterServerManager, pData);
	t.detach();

	return;
}

static void ProcessAtlasConnectionlessPacket(R2::netpacket_t* packet)
{
	bool dbg = Cvar_net_debug_atlas_packet->GetBool();

	// extract kind, null-terminated type, data
	std::string pType, pData;
	for (int i = 5; i < packet->size; i++)
	{
		if (packet->data[i] == '\x00')
		{
			pType.assign((char*)(&packet->data[5]), (size_t)(i - 5));
			if (i + 1 < packet->size)
				pData.assign((char*)(&packet->data[i + 1]), (size_t)(packet->size - i - 1));
			break;
		}
	}

	// note: all Atlas connectionless packets should be idempotent so multiple attempts can be made to mitigate packet loss
	// note: all long-running Atlas connectionless packet handlers should be started in a new thread (with copies of the data) to avoid
	// blocking networking

	// v1 HMACSHA256-signed masterserver request
	if (pType == "sigreq1")
	{
		ProcessAtlasConnectionlessPacketSigreq1(packet, dbg, pType, pData);
		return;
	}

	if (dbg)
		spdlog::warn("ignoring Atlas connectionless packet (size={} type={}): unknown type", packet->size, pType);
	return;
}

AUTOHOOK(ProcessConnectionlessPacket, engine.dll + 0x117800, bool, , (void* a1, R2::netpacket_t* packet))
{
	// packet->data consists of 0xFFFFFFFF (int32 -1) to indicate packets aren't split, followed by a header consisting of a single
	// character, which is used to uniquely identify the packet kind. Most kinds follow this with a null-terminated string payload
	// then an arbitrary amoount of data.

	// T (no rate limits since we authenticate packets before doing anything expensive)
	if (4 < packet->size && packet->data[4] == 'T')
	{
		ProcessAtlasConnectionlessPacket(packet);
		return false;
	}

	// check rate limits for the original unconnected packets
	if (!g_pServerLimits->CheckConnectionlessPacketLimits(packet))
		return false;

	// A, H, I, N
	return ProcessConnectionlessPacket(a1, packet);
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerNetHooks, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(engine.dll)

	if (!InitHMACSHA256())
		throw std::runtime_error("failed to initialize bcrypt");

	if (!VerifyHMACSHA256(
			"test",
			"\x88\xcd\x21\x08\xb5\x34\x7d\x97\x3c\xf3\x9c\xdf\x90\x53\xd7\xdd\x42\x70\x48\x76\xd8\xc9\xa9\xbd\x8e\x2d\x16\x82\x59\xd3\xdd"
			"\xf7",
			"test"))
		throw std::runtime_error("bcrypt HMAC-SHA256 is broken");

	Cvar_net_debug_atlas_packet = new ConVar(
		"net_debug_atlas_packet",
		"0",
		FCVAR_NONE,
		"Whether to log detailed debugging information for Atlas connectionless packets (warning: this allows unlimited amounts of "
		"arbitrary data to be logged)");

	Cvar_net_debug_atlas_packet_insecure = new ConVar(
		"net_debug_atlas_packet_insecure",
		"0",
		FCVAR_NONE,
		"Whether to disable signature verification for Atlas connectionless packets (DANGEROUS: this allows anyone to impersonate Atlas)");
}
