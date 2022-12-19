#include "pch.h"
#include "scripthttprequesthandler.h"
#include "util/version.h"
#include "squirrel/squirrel.h"
#include "core/tier0.h"

HttpRequestHandler* g_httpRequestHandler;

bool IsHttpDisabled()
{
	const static bool bIsHttpDisabled = Tier0::CommandLine()->FindParm("-disablehttprequests");
	return bIsHttpDisabled;
}

bool IsLocalHttpAllowed()
{
	const static bool bIsLocalHttpAllowed = Tier0::CommandLine()->FindParm("-allowlocalhttp");
	return bIsLocalHttpAllowed;
}

bool DisableHttpSsl()
{
	const static bool bDisableHttpSsl = Tier0::CommandLine()->FindParm("-disablehttpssl");
	return bDisableHttpSsl;
}

HttpRequestHandler::HttpRequestHandler()
{
	// Cache the launch parameters as early as possible in order to avoid possible exploits that change them at runtime.
	IsHttpDisabled();
	IsLocalHttpAllowed();
	DisableHttpSsl();
}

void HttpRequestHandler::StartHttpRequestHandler()
{
	if (IsRunning())
	{
		spdlog::warn("%s was called while IsRunning() is true!", __FUNCTION__);
		return;
	}

	m_bIsHttpRequestHandlerRunning = true;
	spdlog::info("HttpRequestHandler started.");
}

void HttpRequestHandler::StopHttpRequestHandler()
{
	if (!IsRunning())
	{
		spdlog::warn("%s was called while IsRunning() is false", __FUNCTION__);
		return;
	}

	m_bIsHttpRequestHandlerRunning = false;
	spdlog::info("HttpRequestHandler stopped.");
}

bool IsHttpDestinationHostAllowed(const std::string& host, std::string& outHostname, std::string& outAddress, std::string& outPort)
{
	CURLU* url = curl_url();
	if (!url)
	{
		spdlog::error("Failed to call curl_url() for http request.");
		return false;
	}

	if (curl_url_set(url, CURLUPART_URL, host.c_str(), CURLU_DEFAULT_SCHEME) != CURLUE_OK)
	{
		spdlog::error("Failed to parse destination URL for http request.");

		curl_url_cleanup(url);
		return false;
	}

	char* urlHostname = nullptr;
	if (curl_url_get(url, CURLUPART_HOST, &urlHostname, 0) != CURLUE_OK)
	{
		spdlog::error("Failed to parse hostname from destination URL for http request.");

		curl_url_cleanup(url);
		return false;
	}

	char* urlScheme = nullptr;
	if (curl_url_get(url, CURLUPART_SCHEME, &urlScheme, CURLU_DEFAULT_SCHEME) != CURLUE_OK)
	{
		spdlog::error("Failed to parse scheme from destination URL for http request.");

		curl_url_cleanup(url);
		curl_free(urlHostname);
		return false;
	}

	char* urlPort = nullptr;
	if (curl_url_get(url, CURLUPART_PORT, &urlPort, CURLU_DEFAULT_PORT) != CURLUE_OK)
	{
		spdlog::error("Failed to parse port from destination URL for http request.");

		curl_url_cleanup(url);
		curl_free(urlHostname);
		curl_free(urlScheme);
		return false;
	}

	// Resolve the hostname into an address.
	addrinfo* result;
	addrinfo hints;
	std::memset(&hints, 0, sizeof(addrinfo));
	hints.ai_family = AF_UNSPEC;

	if (getaddrinfo(urlHostname, urlScheme, &hints, &result) != 0)
	{
		spdlog::error("Failed to resolve http request destination {} using getaddrinfo().", urlHostname);

		curl_url_cleanup(url);
		curl_free(urlHostname);
		curl_free(urlScheme);
		curl_free(urlPort);
		return false;
	}

	bool bFoundIPv6 = false;
	sockaddr_in* sockaddr_ipv4 = nullptr;
	for (addrinfo* info = result; info; info = info->ai_next)
	{
		if (info->ai_family == AF_INET)
		{
			sockaddr_ipv4 = (sockaddr_in*)info->ai_addr;
			break;
		}

		bFoundIPv6 = bFoundIPv6 || info->ai_family == AF_INET6;
	}

	if (sockaddr_ipv4 == nullptr)
	{
		if (bFoundIPv6)
		{
			spdlog::error("Only IPv4 destinations are supported for HTTP requests. To allow IPv6, launch the game using -allowlocalhttp.");
		}
		else
		{
			spdlog::error("Failed to resolve http request destination {} into a valid IPv4 address.", urlHostname);
		}

		curl_free(urlHostname);
		curl_free(urlScheme);
		curl_free(urlPort);
		curl_url_cleanup(url);

		return false;
	}

	// Fast checks for private ranges of IPv4.
	// clang-format off
	{
		auto addrBytes = sockaddr_ipv4->sin_addr.S_un.S_un_b;

		if (addrBytes.s_b1 == 10														// 10.0.0.0			- 10.255.255.255		(Class A Private)
			|| addrBytes.s_b1 == 172 && addrBytes.s_b2 >= 16 && addrBytes.s_b2 <= 31	// 172.16.0.0		- 172.31.255.255		(Class B Private)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 == 168							// 192.168.0.0		- 192.168.255.255		(Class C Private)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 == 0 && addrBytes.s_b3 == 0		// 192.0.0.0		- 192.0.0.255			(IETF Assignment)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 == 0 && addrBytes.s_b3 == 2		// 192.0.2.0		- 192.0.2.255			(TEST-NET-1)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 == 88 && addrBytes.s_b3 == 99	// 192.88.99.0		- 192.88.99.255			(IPv4-IPv6 Relay)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 >= 18 &&	addrBytes.s_b2 <= 19	// 192.18.0.0		- 192.19.255.255		(Internet Benchmark)
			|| addrBytes.s_b1 == 192 && addrBytes.s_b2 == 51 && addrBytes.s_b3 == 100	// 192.51.100.0		- 192.51.100.255		(TEST-NET-2)
			|| addrBytes.s_b1 == 203 && addrBytes.s_b2 == 0 && addrBytes.s_b3 == 113	// 203.0.113.0		- 203.0.113.255			(TEST-NET-3)
			|| addrBytes.s_b1 == 169 && addrBytes.s_b2 == 254							// 169.254.00		- 169.254.255.255		(Link-local/APIPA)
			|| addrBytes.s_b1 == 127													// 127.0.0.0		- 127.255.255.255		(Loopback)
			|| addrBytes.s_b1 == 0														// 0.0.0.0			- 0.255.255.255			(Current network)
			|| addrBytes.s_b1 == 100 && addrBytes.s_b2 >= 64 && addrBytes.s_b2 <= 127	// 100.64.0.0		- 100.127.255.255		(Shared address space)
			|| sockaddr_ipv4->sin_addr.S_un.S_addr == 0xFFFFFFFF						// 255.255.255.255							(Broadcast)
			|| addrBytes.s_b1 >= 224 && addrBytes.s_b2 <= 239							// 224.0.0.0		- 239.255.255.255		(Multicast)
			|| addrBytes.s_b1 == 233 && addrBytes.s_b2 == 252 && addrBytes.s_b3 == 0	// 233.252.0.0		- 233.252.0.255			(MCAST-TEST-NET)
			|| addrBytes.s_b1 >= 240 && addrBytes.s_b4 <= 254)							// 240.0.0.0		- 255.255.255.254		(Future Use Class E)
		{
			curl_free(urlHostname);
			curl_free(urlScheme);
			curl_free(urlPort);
			curl_url_cleanup(url);

			return false;
		}
	}

	// clang-format on

	char resolvedStr[INET_ADDRSTRLEN];
	inet_ntop(AF_INET, &sockaddr_ipv4->sin_addr, resolvedStr, INET_ADDRSTRLEN);

	// Use the resolved address as the new request host.
	outHostname = urlHostname;
	outAddress = resolvedStr;
	outPort = urlPort;

	freeaddrinfo(result);

	curl_free(urlHostname);
	curl_free(urlScheme);
	curl_free(urlPort);
	curl_url_cleanup(url);

	return true;
}

size_t HttpCurlWriteToStringBufferCallback(char* contents, size_t size, size_t nmemb, void* userp)
{
	((std::string*)userp)->append((char*)contents, size * nmemb);
	return size * nmemb;
}

template <ScriptContext context> int HttpRequestHandler::MakeHttpRequest(const HttpRequest& requestParameters)
{
	if (!IsRunning())
	{
		spdlog::warn("%s was called while IsRunning() is false!", __FUNCTION__);
		return -1;
	}

	if (IsHttpDisabled())
	{
		spdlog::warn("NS_InternalMakeHttpRequest called while the game is running with -disablehttprequests."
					 " Please check if requests are allowed using NSIsHttpEnabled() first.");
		return -1;
	}

	bool bAllowLocalHttp = IsLocalHttpAllowed();

	// This handle will be returned to Squirrel so it can wait for the response and assign a callback for it.
	int handle = ++m_iLastRequestHandle;

	std::thread requestThread(
		[this, handle, requestParameters, bAllowLocalHttp]()
		{
			std::string hostname, resolvedAddress, resolvedPort;

			if (!bAllowLocalHttp)
			{
				if (!IsHttpDestinationHostAllowed(requestParameters.baseUrl, hostname, resolvedAddress, resolvedPort))
				{
					spdlog::warn(
						"HttpRequestHandler::MakeHttpRequest attempted to make a request to a private network. This is only allowed when "
						"running the game with -allowlocalhttp.");
					g_pSquirrel<context>->AsyncCall(
						"NSHandleFailedHttpRequest",
						handle,
						(int)0,
						"Cannot make HTTP requests to private network hosts without -allowlocalhttp. Check your console for more "
						"information.");
					return;
				}
			}

			CURL* curl = curl_easy_init();
			if (!curl)
			{
				spdlog::error("HttpRequestHandler::MakeHttpRequest failed to init libcurl for request.");
				g_pSquirrel<context>->AsyncCall(
					"NSHandleFailedHttpRequest", handle, static_cast<int>(CURLE_FAILED_INIT), curl_easy_strerror(CURLE_FAILED_INIT));
				return;
			}

			// HEAD has no body.
			if (requestParameters.method == HttpRequestMethod::HRM_HEAD)
			{
				curl_easy_setopt(curl, CURLOPT_NOBODY, 1L);
			}

			curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, HttpRequestMethod::ToString(requestParameters.method).c_str());

			// Only resolve to IPv4 if we don't allow private network requests.
			curl_slist* host = nullptr;
			if (!bAllowLocalHttp)
			{
				curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
				host = curl_slist_append(host, fmt::format("{}:{}:{}", hostname, resolvedPort, resolvedAddress).c_str());
				curl_easy_setopt(curl, CURLOPT_RESOLVE, host);
			}

			// Ensure we only allow HTTP or HTTPS.
			curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTP | CURLPROTO_HTTPS);

			// Allow redirects
			curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
			curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 3L);

			// Check if the url already contains a query.
			// If so, we'll know to append with & instead of start with ?
			std::string queryUrl = requestParameters.baseUrl;
			bool bUrlContainsQuery = false;

			// If this fails, just ignore the parsing and trust what the user wants to query.
			// Probably will fail but handling it here would be annoying.
			CURLU* curlUrl = curl_url();
			if (curlUrl)
			{
				if (curl_url_set(curlUrl, CURLUPART_URL, queryUrl.c_str(), CURLU_DEFAULT_SCHEME) == CURLUE_OK)
				{
					char* currentQuery;
					if (curl_url_get(curlUrl, CURLUPART_QUERY, &currentQuery, 0) == CURLUE_OK)
					{
						if (currentQuery && std::strlen(currentQuery) != 0)
						{
							bUrlContainsQuery = true;
						}
					}

					curl_free(currentQuery);
				}

				curl_url_cleanup(curlUrl);
			}

			// GET requests, or POST-like requests with an empty body, can have query parameters.
			// Append them to the base url.
			if (HttpRequestMethod::CanHaveQueryParameters(requestParameters.method) &&
					!HttpRequestMethod::UsesCurlPostOptions(requestParameters.method) ||
				requestParameters.body.empty())
			{
				bool isFirstValue = true;
				for (const auto& kv : requestParameters.queryParameters)
				{
					char* key = curl_easy_escape(curl, kv.first.c_str(), kv.first.length());

					for (const std::string& queryValue : kv.second)
					{
						char* value = curl_easy_escape(curl, queryValue.c_str(), queryValue.length());

						if (isFirstValue && !bUrlContainsQuery)
						{
							queryUrl.append(fmt::format("?{}={}", key, value));
							isFirstValue = false;
						}
						else
						{
							queryUrl.append(fmt::format("&{}={}", key, value));
						}

						curl_free(value);
					}

					curl_free(key);
				}
			}

			// If this method uses POST-like curl options, set those and set the body.
			// The body won't be sent if it's empty anyway, meaning the query parameters above, if any, would be.
			if (HttpRequestMethod::UsesCurlPostOptions(requestParameters.method))
			{
				// Grab the body and set it as a POST field
				curl_easy_setopt(curl, CURLOPT_POST, 1L);

				curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, requestParameters.body.length());
				curl_easy_setopt(curl, CURLOPT_COPYPOSTFIELDS, requestParameters.body.c_str());
			}

			// Set the full URL for this http request.
			curl_easy_setopt(curl, CURLOPT_URL, queryUrl.c_str());

			std::string bodyBuffer;
			std::string headerBuffer;

			// Set up buffers to write the response headers and body.
			curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, HttpCurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, &bodyBuffer);
			curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HttpCurlWriteToStringBufferCallback);
			curl_easy_setopt(curl, CURLOPT_HEADERDATA, &headerBuffer);

			// Add all the headers for the request.
			curl_slist* headers = nullptr;

			// Content-Type header for POST-like requests.
			if (HttpRequestMethod::UsesCurlPostOptions(requestParameters.method) && !requestParameters.body.empty())
			{
				headers = curl_slist_append(headers, fmt::format("Content-Type: {}", requestParameters.contentType).c_str());
			}

			for (const auto& kv : requestParameters.headers)
			{
				for (const std::string& headerValue : kv.second)
				{
					headers = curl_slist_append(headers, fmt::format("{}: {}", kv.first, headerValue).c_str());
				}
			}

			if (headers != nullptr)
			{
				curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
			}

			// Disable SSL checks if requested by the user.
			if (DisableHttpSsl())
			{
				curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
				curl_easy_setopt(curl, CURLOPT_SSL_VERIFYSTATUS, 0L);
			}

			// Enforce the Northstar user agent, unless an override was specified.
			if (requestParameters.userAgent.empty())
			{
				curl_easy_setopt(curl, CURLOPT_USERAGENT, &NSUserAgent);
			}
			else
			{
				curl_easy_setopt(curl, CURLOPT_USERAGENT, requestParameters.userAgent.c_str());
			}

			// Set the timeout for this request. Max 60 seconds so mods can't just spin up native threads all the time.
			curl_easy_setopt(curl, CURLOPT_TIMEOUT, std::clamp<long>(requestParameters.timeout, 1, 60));

			CURLcode result = curl_easy_perform(curl);
			if (IsRunning())
			{
				if (result == CURLE_OK)
				{
					// While the curl request is OK, it could return a non success code.
					// Squirrel side will handle firing the correct callback.
					long httpCode = 0;
					curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
					g_pSquirrel<context>->AsyncCall(
						"NSHandleSuccessfulHttpRequest", handle, static_cast<int>(httpCode), bodyBuffer, headerBuffer);
				}
				else
				{
					// Pass CURL result code & error.
					spdlog::error(
						"curl_easy_perform() failed with code {}, error: {}", static_cast<int>(result), curl_easy_strerror(result));

					// If it's an SSL issue, tell the user they may disable SSL checks using -disablehttpssl.
					if (result == CURLE_PEER_FAILED_VERIFICATION || result == CURLE_SSL_CERTPROBLEM ||
						result == CURLE_SSL_INVALIDCERTSTATUS)
					{
						spdlog::error("You can try disabling SSL verifications for this issue using the -disablehttpssl launch argument. "
									  "Keep in mind this is potentially dangerous!");
					}

					g_pSquirrel<context>->AsyncCall(
						"NSHandleFailedHttpRequest", handle, static_cast<int>(result), curl_easy_strerror(result));
				}
			}

			curl_easy_cleanup(curl);
			curl_slist_free_all(headers);
			curl_slist_free_all(host);
		});

	requestThread.detach();
	return handle;
}

template <ScriptContext context> void HttpRequestHandler::RegisterSQFuncs()
{
	g_pSquirrel<context>->AddFuncRegistration(
		"int",
		"NS_InternalMakeHttpRequest",
		"int method, string baseUrl, table<string, array<string> > headers, table<string, array<string> > queryParams, string contentType, "
		"string body, "
		"int timeout, string userAgent",
		"[Internal use only] Passes the HttpRequest struct fields to be reconstructed in native and used for an http request",
		SQ_InternalMakeHttpRequest<context>);

	g_pSquirrel<context>->AddFuncRegistration(
		"bool",
		"NSIsHttpEnabled",
		"",
		"Whether or not HTTP requests are enabled. You can opt-out by starting the game with -disablehttprequests.",
		SQ_IsHttpEnabled<context>);

	g_pSquirrel<context>->AddFuncRegistration(
		"bool",
		"NSIsLocalHttpAllowed",
		"",
		"Whether or not HTTP requests can be made to a private network address. You can enable this by starting the game with "
		"-allowlocalhttp.",
		SQ_IsLocalHttpAllowed<context>);
}

// int NS_InternalMakeHttpRequest(int method, string baseUrl, table<string, string> headers, table<string, string> queryParams,
//	string contentType, string body, int timeout, string userAgent)
template <ScriptContext context> SQRESULT SQ_InternalMakeHttpRequest(HSquirrelVM* sqvm)
{
	if (!g_httpRequestHandler || !g_httpRequestHandler->IsRunning())
	{
		spdlog::warn("NS_InternalMakeHttpRequest called while the http request handler isn't running.");
		g_pSquirrel<context>->pushinteger(sqvm, -1);
		return SQRESULT_NOTNULL;
	}

	if (IsHttpDisabled())
	{
		spdlog::warn("NS_InternalMakeHttpRequest called while the game is running with -disablehttprequests."
					 " Please check if requests are allowed using NSIsHttpEnabled() first.");
		g_pSquirrel<context>->pushinteger(sqvm, -1);
		return SQRESULT_NOTNULL;
	}

	HttpRequest request;
	request.method = static_cast<HttpRequestMethod::Type>(g_pSquirrel<context>->getinteger(sqvm, 1));
	request.baseUrl = g_pSquirrel<context>->getstring(sqvm, 2);

	// Read the tables for headers and query parameters.
	SQTable* headerTable = sqvm->_stackOfCurrentFunction[3]._VAL.asTable;
	for (int idx = 0; idx < headerTable->_numOfNodes; ++idx)
	{
		tableNode* node = &headerTable->_nodes[idx];

		if (node->key._Type == OT_STRING && node->val._Type == OT_ARRAY)
		{
			SQArray* valueArray = node->val._VAL.asArray;
			std::vector<std::string> headerValues;

			for (int vIdx = 0; vIdx < valueArray->_usedSlots; ++vIdx)
			{
				if (valueArray->_values[vIdx]._Type == OT_STRING)
				{
					headerValues.push_back(valueArray->_values[vIdx]._VAL.asString->_val);
				}
			}

			request.headers[node->key._VAL.asString->_val] = headerValues;
		}
	}

	SQTable* queryTable = sqvm->_stackOfCurrentFunction[4]._VAL.asTable;
	for (int idx = 0; idx < queryTable->_numOfNodes; ++idx)
	{
		tableNode* node = &queryTable->_nodes[idx];

		if (node->key._Type == OT_STRING && node->val._Type == OT_ARRAY)
		{
			SQArray* valueArray = node->val._VAL.asArray;
			std::vector<std::string> queryValues;

			for (int vIdx = 0; vIdx < valueArray->_usedSlots; ++vIdx)
			{
				if (valueArray->_values[vIdx]._Type == OT_STRING)
				{
					queryValues.push_back(valueArray->_values[vIdx]._VAL.asString->_val);
				}
			}

			request.queryParameters[node->key._VAL.asString->_val] = queryValues;
		}
	}

	request.contentType = g_pSquirrel<context>->getstring(sqvm, 5);
	request.body = g_pSquirrel<context>->getstring(sqvm, 6);
	request.timeout = g_pSquirrel<context>->getinteger(sqvm, 7);
	request.userAgent = g_pSquirrel<context>->getstring(sqvm, 8);

	int handle = g_httpRequestHandler->MakeHttpRequest<context>(request);
	g_pSquirrel<context>->pushinteger(sqvm, handle);
	return SQRESULT_NOTNULL;
}

// bool NSIsHttpEnabled()
template <ScriptContext context> SQRESULT SQ_IsHttpEnabled(HSquirrelVM* sqvm)
{
	g_pSquirrel<context>->pushbool(sqvm, !IsHttpDisabled());
	return SQRESULT_NOTNULL;
}

// bool NSIsLocalHttpAllowed()
template <ScriptContext context> SQRESULT SQ_IsLocalHttpAllowed(HSquirrelVM* sqvm)
{
	g_pSquirrel<context>->pushbool(sqvm, IsLocalHttpAllowed());
	return SQRESULT_NOTNULL;
}

ON_DLL_LOAD_RELIESON("client.dll", HttpRequestHandler_ClientInit, ClientSquirrel, (CModule module))
{
	g_httpRequestHandler->RegisterSQFuncs<ScriptContext::CLIENT>();
	g_httpRequestHandler->RegisterSQFuncs<ScriptContext::UI>();
}

ON_DLL_LOAD_RELIESON("server.dll", HttpRequestHandler_ServerInit, ServerSquirrel, (CModule module))
{
	g_httpRequestHandler->RegisterSQFuncs<ScriptContext::SERVER>();
}

ON_DLL_LOAD("engine.dll", HttpRequestHandler_Init, (CModule module))
{
	g_httpRequestHandler = new HttpRequestHandler;
	g_httpRequestHandler->StartHttpRequestHandler();
}
