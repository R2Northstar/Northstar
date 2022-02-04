#pragma once

#define INLINE inline

#define BITS_PER_INT 32

INLINE int GetBitForBitnum(int bitNum)
{
	static int bitsForBitnum[] = {
		(1 << 0),  (1 << 1),  (1 << 2),	 (1 << 3),	(1 << 4),  (1 << 5),  (1 << 6),	 (1 << 7),	(1 << 8),  (1 << 9),  (1 << 10),
		(1 << 11), (1 << 12), (1 << 13), (1 << 14), (1 << 15), (1 << 16), (1 << 17), (1 << 18), (1 << 19), (1 << 20), (1 << 21),
		(1 << 22), (1 << 23), (1 << 24), (1 << 25), (1 << 26), (1 << 27), (1 << 28), (1 << 29), (1 << 30), (1 << 31),
	};

	return bitsForBitnum[(bitNum) & (BITS_PER_INT - 1)];
}

#undef BITS_PER_INT

using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;
using uptr = uintptr_t;

using i8 = int8_t;
using i16 = int16_t;
using i32 = int32_t;
using i64 = int64_t;
using iptr = intptr_t;

// Endianess, don't use on PPC64 nor ARM64BE
#define LittleDWord(val) (val)

static INLINE void StoreLittleDWord(u32* base, size_t dwordIndex, u32 dword) { base[dwordIndex] = LittleDWord(dword); }

static INLINE u32 LoadLittleDWord(u32* base, size_t dwordIndex) { return LittleDWord(base[dwordIndex]); }

#include <algorithm>

static inline const u32 s_nMaskTable[33] = {
	0,
	(1 << 1) - 1,
	(1 << 2) - 1,
	(1 << 3) - 1,
	(1 << 4) - 1,
	(1 << 5) - 1,
	(1 << 6) - 1,
	(1 << 7) - 1,
	(1 << 8) - 1,
	(1 << 9) - 1,
	(1 << 10) - 1,
	(1 << 11) - 1,
	(1 << 12) - 1,
	(1 << 13) - 1,
	(1 << 14) - 1,
	(1 << 15) - 1,
	(1 << 16) - 1,
	(1 << 17) - 1,
	(1 << 18) - 1,
	(1 << 19) - 1,
	(1 << 20) - 1,
	(1 << 21) - 1,
	(1 << 22) - 1,
	(1 << 23) - 1,
	(1 << 24) - 1,
	(1 << 25) - 1,
	(1 << 26) - 1,
	(1 << 27) - 1,
	(1 << 28) - 1,
	(1 << 29) - 1,
	(1 << 30) - 1,
	0x7fffffff,
	0xffffffff,
};

enum EBitCoordType
{
	kCW_None,
	kCW_LowPrecision,
	kCW_Integral
};

class BitBufferBase
{
  protected:
	INLINE void SetName(const char* name) { m_BufferName = name; }

  public:
	INLINE bool IsOverflowed() { return m_Overflow; }
	INLINE void SetOverflowed() { m_Overflow = true; }

	INLINE const char* GetName() { return m_BufferName; }

  private:
	const char* m_BufferName = "";

  protected:
	u8 m_Overflow = false;
};

class BFRead : public BitBufferBase
{
  public:
	BFRead() = default;

	INLINE BFRead(uptr data, size_t byteLength, size_t startPos = 0, const char* bufferName = 0)
	{
		StartReading(data, byteLength, startPos);

		if (bufferName)
			SetName(bufferName);
	}

  public:
	INLINE void StartReading(uptr data, size_t byteLength, size_t startPos = 0)
	{
		m_Data = reinterpret_cast<u32 const*>(data);
		m_DataIn = m_Data;

		m_DataBytes = byteLength;
		m_DataBits = byteLength << 3;

		m_DataEnd = reinterpret_cast<u32 const*>(reinterpret_cast<u8 const*>(m_Data) + m_DataBytes);

		Seek(startPos);
	}

	INLINE void GrabNextDWord(bool overflow = false)
	{
		if (m_Data == m_DataEnd)
		{
			m_CachedBitsLeft = 1;
			m_CachedBufWord = 0;

			m_DataIn++;

			if (overflow)
				SetOverflowed();
		}
		else
		{
			if (m_DataIn > m_DataEnd)
			{
				SetOverflowed();
				m_CachedBufWord = 0;
			}
			else
			{
				m_CachedBufWord = LittleDWord(*(m_DataIn++));
			}
		}
	}

	INLINE void FetchNext()
	{
		m_CachedBitsLeft = 32;
		GrabNextDWord(false);
	}

	INLINE i32 ReadOneBit()
	{
		i32 ret = m_CachedBufWord & 1;

		if (--m_CachedBitsLeft == 0)
			FetchNext();
		else
			m_CachedBufWord >>= 1;

		return ret;
	}

	INLINE u32 ReadUBitLong(i32 numBits)
	{
		if (m_CachedBitsLeft >= numBits)
		{
			u32 ret = m_CachedBufWord & s_nMaskTable[numBits];

			m_CachedBitsLeft -= numBits;

			if (m_CachedBitsLeft)
				m_CachedBufWord >>= numBits;
			else
				FetchNext();

			return ret;
		}
		else
		{
			// need to merge words
			u32 ret = m_CachedBufWord;
			numBits -= m_CachedBitsLeft;

			GrabNextDWord(true);

			if (IsOverflowed())
				return 0;

			ret |= ((m_CachedBufWord & s_nMaskTable[numBits]) << m_CachedBitsLeft);

			m_CachedBitsLeft = 32 - numBits;
			m_CachedBufWord >>= numBits;

			return ret;
		}
	}

	INLINE i32 ReadSBitLong(int numBits)
	{
		i32 ret = ReadUBitLong(numBits);
		return (ret << (32 - numBits)) >> (32 - numBits);
	}

	INLINE u32 ReadUBitVar()
	{
		u32 ret = ReadUBitLong(6);

		switch (ret & (16 | 32))
		{
		case 16:
			ret = (ret & 15) | (ReadUBitLong(4) << 4);
			// Assert(ret >= 16);
			break;
		case 32:
			ret = (ret & 15) | (ReadUBitLong(8) << 4);
			// Assert(ret >= 256);
			break;
		case 48:
			ret = (ret & 15) | (ReadUBitLong(32 - 4) << 4);
			// Assert(ret >= 4096);
			break;
		}

		return ret;
	}

	INLINE u32 PeekUBitLong(i32 numBits)
	{
		i32 nSaveBA = m_CachedBitsLeft;
		i32 nSaveW = m_CachedBufWord;
		u32 const* pSaveP = m_DataIn;
		u32 nRet = ReadUBitLong(numBits);

		m_CachedBitsLeft = nSaveBA;
		m_CachedBufWord = nSaveW;
		m_DataIn = pSaveP;

		return nRet;
	}

	INLINE float ReadBitFloat()
	{
		u32 value = ReadUBitLong(32);
		return *reinterpret_cast<float*>(&value);
	}

	/*INLINE float ReadBitCoord() {
		i32   intval = 0, fractval = 0, signbit = 0;
		float value = 0.0;

		// Read the required integer and fraction flags
		intval = ReadOneBit();
		fractval = ReadOneBit();

		// If we got either parse them, otherwise it's a zero.
		if (intval || fractval) {
			// Read the sign bit
			signbit = ReadOneBit();

			// If there's an integer, read it in
			if (intval) {
				// Adjust the integers from [0..MAX_COORD_VALUE-1] to [1..MAX_COORD_VALUE]
				intval = ReadUBitLong(COORD_INTEGER_BITS) + 1;
			}

			// If there's a fraction, read it in
			if (fractval) {
				fractval = ReadUBitLong(COORD_FRACTIONAL_BITS);
			}

			// Calculate the correct floating point value
			value = intval + ((float)fractval * COORD_RESOLUTION);

			// Fixup the sign if negative.
			if (signbit)
				value = -value;
		}

		return value;
	}

	INLINE float ReadBitCoordMP() {
		i32   intval = 0, fractval = 0, signbit = 0;
		float value = 0.0;

		bool inBounds = ReadOneBit() ? true : false;

		// Read the required integer and fraction flags
		intval = ReadOneBit();

		// If we got either parse them, otherwise it's a zero.
		if (intval) {
			// Read the sign bit
			signbit = ReadOneBit();

			// If there's an integer, read it in
			// Adjust the integers from [0..MAX_COORD_VALUE-1] to [1..MAX_COORD_VALUE]
			if (inBounds)
				value = ReadUBitLong(COORD_INTEGER_BITS_MP) + 1;
			else
				value = ReadUBitLong(COORD_INTEGER_BITS) + 1;
		}

		// Fixup the sign if negative.
		if (signbit)
			value = -value;

		return value;
	}

	INLINE float ReadBitCellCoord(int bits, EBitCoordType coordType) {
		bool bIntegral = (coordType == kCW_Integral);
		bool bLowPrecision = (coordType == kCW_LowPrecision);

		int   intval = 0, fractval = 0;
		float value = 0.0;

		if (bIntegral)
			value = ReadUBitLong(bits);
		else {
			intval = ReadUBitLong(bits);

			// If there's a fraction, read it in
			fractval = ReadUBitLong(bLowPrecision ? COORD_FRACTIONAL_BITS_MP_LOWPRECISION : COORD_FRACTIONAL_BITS);

			// Calculate the correct floating point value
			value = intval + ((float)fractval * (bLowPrecision ? COORD_RESOLUTION_LOWPRECISION : COORD_RESOLUTION));
		}

		return value;
	}

	INLINE float ReadBitNormal() {
		// Read the sign bit
		i32 signbit = ReadOneBit();

		// Read the fractional part
		u32 fractval = ReadUBitLong(NORMAL_FRACTIONAL_BITS);

		// Calculate the correct floating point value
		float value = (float)fractval * NORMAL_RESOLUTION;

		// Fixup the sign if negative.
		if (signbit)
			value = -value;

		return value;
	}

	INLINE void ReadBitVec3Coord(Vector& fa) {
		i32 xflag, yflag, zflag;

		// This vector must be initialized! Otherwise, If any of the flags aren't set,
		// the corresponding component will not be read and will be stack garbage.
		fa.Init(0, 0, 0);

		xflag = ReadOneBit();
		yflag = ReadOneBit();
		zflag = ReadOneBit();

		if (xflag)
			fa[0] = ReadBitCoord();
		if (yflag)
			fa[1] = ReadBitCoord();
		if (zflag)
			fa[2] = ReadBitCoord();
	}

	INLINE void ReadBitVec3Normal(Vector& fa) {
		i32 xflag = ReadOneBit();
		i32 yflag = ReadOneBit();

		if (xflag)
			fa[0] = ReadBitNormal();
		else
			fa[0] = 0.0f;

		if (yflag)
			fa[1] = ReadBitNormal();
		else
			fa[1] = 0.0f;

		// The first two imply the third (but not its sign)
		i32 znegative = ReadOneBit();

		float fafafbfb = fa[0] * fa[0] + fa[1] * fa[1];
		if (fafafbfb < 1.0f)
			fa[2] = sqrt(1.0f - fafafbfb);
		else
			fa[2] = 0.0f;

		if (znegative)
			fa[2] = -fa[2];
	}

	INLINE void ReadBitAngles(QAngle& fa) {
		Vector tmp;
		ReadBitVec3Coord(tmp);
		fa.Init(tmp.x, tmp.y, tmp.z);
	}*/

	INLINE float ReadBitAngle(int numBits)
	{
		float shift = (float)(GetBitForBitnum(numBits));

		i32 i = ReadUBitLong(numBits);
		float fReturn = (float)i * (360.0 / shift);

		return fReturn;
	}

	INLINE i32 ReadChar() { return ReadSBitLong(sizeof(char) << 3); }
	INLINE u32 ReadByte() { return ReadUBitLong(sizeof(unsigned char) << 3); }

	INLINE i32 ReadShort() { return ReadSBitLong(sizeof(short) << 3); }
	INLINE u32 ReadWord() { return ReadUBitLong(sizeof(unsigned short) << 3); }

	INLINE i32 ReadLong() { return (i32)(ReadUBitLong(sizeof(i32) << 3)); }
	INLINE float ReadFloat()
	{
		u32 temp = ReadUBitLong(sizeof(float) << 3);
		return *reinterpret_cast<float*>(&temp);
	}

	INLINE u32 ReadVarInt32()
	{
		constexpr int kMaxVarint32Bytes = 5;

		u32 result = 0;
		int count = 0;
		u32 b;

		do
		{
			if (count == kMaxVarint32Bytes)
				return result;

			b = ReadUBitLong(8);
			result |= (b & 0x7F) << (7 * count);
			++count;
		} while (b & 0x80);

		return result;
	}

	INLINE u64 ReadVarInt64()
	{
		constexpr int kMaxVarintBytes = 10;

		u64 result = 0;
		int count = 0;
		u64 b;

		do
		{
			if (count == kMaxVarintBytes)
				return result;

			b = ReadUBitLong(8);
			result |= static_cast<u64>(b & 0x7F) << (7 * count);
			++count;
		} while (b & 0x80);

		return result;
	}

	INLINE void ReadBits(uptr outData, u32 bitLength)
	{
		u8* out = reinterpret_cast<u8*>(outData);
		int bitsLeft = bitLength;

		// align output to dword boundary
		while (((uptr)out & 3) != 0 && bitsLeft >= 8)
		{
			*out = (unsigned char)ReadUBitLong(8);
			++out;
			bitsLeft -= 8;
		}

		// read dwords
		while (bitsLeft >= 32)
		{
			*((u32*)out) = ReadUBitLong(32);
			out += sizeof(u32);
			bitsLeft -= 32;
		}

		// read remaining bytes
		while (bitsLeft >= 8)
		{
			*out = ReadUBitLong(8);
			++out;
			bitsLeft -= 8;
		}

		// read remaining bits
		if (bitsLeft)
			*out = ReadUBitLong(bitsLeft);
	}

	INLINE bool ReadBytes(uptr outData, u32 byteLength)
	{
		ReadBits(outData, byteLength << 3);
		return !IsOverflowed();
	}

	INLINE bool ReadString(char* str, i32 maxLength, bool stopAtLineTermination = false, i32* outNumChars = 0)
	{
		bool tooSmall = false;
		int iChar = 0;

		while (1)
		{
			char val = ReadChar();

			if (val == 0)
				break;
			else if (stopAtLineTermination && val == '\n')
				break;

			if (iChar < (maxLength - 1))
			{
				str[iChar] = val;
				++iChar;
			}
			else
			{
				tooSmall = true;
			}
		}

		// Make sure it's null-terminated.
		// Assert(iChar < maxLength);
		str[iChar] = 0;

		if (outNumChars)
			*outNumChars = iChar;

		return !IsOverflowed() && !tooSmall;
	}

	INLINE char* ReadAndAllocateString(bool* hasOverflowed = 0)
	{
		char str[2048];

		int chars = 0;
		bool overflowed = !ReadString(str, sizeof(str), false, &chars);

		if (hasOverflowed)
			*hasOverflowed = overflowed;

		// Now copy into the output and return it;
		char* ret = new char[chars + 1];
		for (u32 i = 0; i <= chars; i++)
			ret[i] = str[i];

		return ret;
	}

	INLINE i64 ReadLongLong()
	{
		i64 retval;
		u32* longs = (u32*)&retval;

		// Read the two DWORDs according to network endian
		const short endianIndex = 0x0100;
		u8* idx = (u8*)&endianIndex;

		longs[*idx++] = ReadUBitLong(sizeof(i32) << 3);
		longs[*idx] = ReadUBitLong(sizeof(i32) << 3);

		return retval;
	}

	INLINE bool Seek(size_t startPos)
	{
		bool bSucc = true;

		if (startPos < 0 || startPos > m_DataBits)
		{
			SetOverflowed();
			bSucc = false;
			startPos = m_DataBits;
		}

		// non-multiple-of-4 bytes at head of buffer. We put the "round off"
		// at the head to make reading and detecting the end efficient.
		int nHead = m_DataBytes & 3;

		int posBytes = startPos / 8;
		if ((m_DataBytes < 4) || (nHead && (posBytes < nHead)))
		{
			// partial first dword
			u8 const* partial = (u8 const*)m_Data;

			if (m_Data)
			{
				m_CachedBufWord = *(partial++);
				if (nHead > 1)
					m_CachedBufWord |= (*partial++) << 8;
				if (nHead > 2)
					m_CachedBufWord |= (*partial++) << 16;
			}

			m_DataIn = (u32 const*)partial;

			m_CachedBufWord >>= (startPos & 31);
			m_CachedBitsLeft = (nHead << 3) - (startPos & 31);
		}
		else
		{
			int adjustedPos = startPos - (nHead << 3);

			m_DataIn = reinterpret_cast<u32 const*>(reinterpret_cast<u8 const*>(m_Data) + ((adjustedPos / 32) << 2) + nHead);

			if (m_Data)
			{
				m_CachedBitsLeft = 32;
				GrabNextDWord();
			}
			else
			{
				m_CachedBufWord = 0;
				m_CachedBitsLeft = 1;
			}

			m_CachedBufWord >>= (adjustedPos & 31);
			m_CachedBitsLeft = std::min(m_CachedBitsLeft, u32(32 - (adjustedPos & 31))); // in case grabnextdword overflowed
		}

		return bSucc;
	}

	INLINE size_t GetNumBitsRead()
	{
		if (!m_Data)
			return 0;

		size_t nCurOfs = size_t(((iptr(m_DataIn) - iptr(m_Data)) / 4) - 1);
		nCurOfs *= 32;
		nCurOfs += (32 - m_CachedBitsLeft);

		size_t nAdjust = 8 * (m_DataBytes & 3);
		return std::min(nCurOfs + nAdjust, m_DataBits);
	}

	INLINE bool SeekRelative(size_t offset) { return Seek(GetNumBitsRead() + offset); }

	INLINE size_t TotalBytesAvailable() { return m_DataBytes; }

	INLINE size_t GetNumBitsLeft() { return m_DataBits - GetNumBitsRead(); }
	INLINE size_t GetNumBytesLeft() { return GetNumBitsLeft() >> 3; }

  private:
	size_t m_DataBits;	// 0x0010
	size_t m_DataBytes; // 0x0018

	u32 m_CachedBufWord;  // 0x0020
	u32 m_CachedBitsLeft; // 0x0024

	const u32* m_DataIn;  // 0x0028
	const u32* m_DataEnd; // 0x0030
	const u32* m_Data;	  // 0x0038
};

class BFWrite : public BitBufferBase
{
  public:
	BFWrite() = default;

	INLINE BFWrite(uptr data, size_t byteLength, const char* bufferName = 0)
	{
		StartWriting(data, byteLength);

		if (bufferName)
			SetName(bufferName);
	}

  public:
	INLINE void StartWriting(uptr data, size_t byteLength)
	{
		m_Data = reinterpret_cast<u32*>(data);
		m_DataOut = m_Data;

		m_DataBytes = byteLength;
		m_DataBits = byteLength << 3;

		m_DataEnd = reinterpret_cast<u32*>(reinterpret_cast<u8*>(m_Data) + m_DataBytes);
	}

	INLINE int GetNumBitsLeft() { return m_OutBitsLeft + (32 * (m_DataEnd - m_DataOut - 1)); }

	INLINE void Reset()
	{
		m_Overflow = false;
		m_OutBufWord = 0;
		m_OutBitsLeft = 32;
		m_DataOut = m_Data;
	}

	INLINE void TempFlush()
	{
		if (m_OutBitsLeft != 32)
		{
			if (m_DataOut == m_DataEnd)
				SetOverflowed();
			else
				StoreLittleDWord(m_DataOut, 0, LoadLittleDWord(m_DataOut, 0) & ~s_nMaskTable[32 - m_OutBitsLeft] | m_OutBufWord);
		}

		m_Flushed = true;
	}

	INLINE u8* GetBasePointer()
	{
		TempFlush();
		return reinterpret_cast<u8*>(m_Data);
	}

	INLINE u8* GetData() { return GetBasePointer(); }

	INLINE void Finish()
	{
		if (m_OutBitsLeft != 32)
		{
			if (m_DataOut == m_DataEnd)
				SetOverflowed();

			StoreLittleDWord(m_DataOut, 0, m_OutBufWord);
		}
	}

	INLINE void FlushNoCheck()
	{
		StoreLittleDWord(m_DataOut++, 0, m_OutBufWord);

		m_OutBitsLeft = 32;
		m_OutBufWord = 0;
	}

	INLINE void Flush()
	{
		if (m_DataOut == m_DataEnd)
			SetOverflowed();
		else
			StoreLittleDWord(m_DataOut++, 0, m_OutBufWord);

		m_OutBitsLeft = 32;
		m_OutBufWord = 0;
	}

	INLINE void WriteOneBitNoCheck(i32 value)
	{
		m_OutBufWord |= (value & 1) << (32 - m_OutBitsLeft);

		if (--m_OutBitsLeft == 0)
			FlushNoCheck();
	}

	INLINE void WriteOneBit(i32 value)
	{
		m_OutBufWord |= (value & 1) << (32 - m_OutBitsLeft);

		if (--m_OutBitsLeft == 0)
			Flush();
	}

	INLINE void WriteUBitLong(u32 data, i32 numBits, bool checkRange = true)
	{
		if (numBits <= m_OutBitsLeft)
		{
			if (checkRange)
				m_OutBufWord |= (data) << (32 - m_OutBitsLeft);
			else
				m_OutBufWord |= (data & s_nMaskTable[numBits]) << (32 - m_OutBitsLeft);

			m_OutBitsLeft -= numBits;

			if (m_OutBitsLeft == 0)
				Flush();
		}
		else
		{
			// split dwords case
			i32 overflowBits = (numBits - m_OutBitsLeft);
			m_OutBufWord |= (data & s_nMaskTable[m_OutBitsLeft]) << (32 - m_OutBitsLeft);
			Flush();
			m_OutBufWord = (data >> (numBits - overflowBits));
			m_OutBitsLeft = 32 - overflowBits;
		}
	}

	INLINE void WriteSBitLong(i32 data, i32 numBits) { WriteUBitLong((u32)data, numBits, false); }

	INLINE void WriteUBitVar(u32 n)
	{
		if (n < 16)
			WriteUBitLong(n, 6);
		else if (n < 256)
			WriteUBitLong((n & 15) | 16 | ((n & (128 | 64 | 32 | 16)) << 2), 10);
		else if (n < 4096)
			WriteUBitLong((n & 15) | 32 | ((n & (2048 | 1024 | 512 | 256 | 128 | 64 | 32 | 16)) << 2), 14);
		else
		{
			WriteUBitLong((n & 15) | 48, 6);
			WriteUBitLong((n >> 4), 32 - 4);
		}
	}

	INLINE void WriteBitFloat(float value)
	{
		auto temp = &value;
		WriteUBitLong(*reinterpret_cast<u32*>(temp), 32);
	}

	INLINE void WriteFloat(float value)
	{
		auto temp = &value;
		WriteUBitLong(*reinterpret_cast<u32*>(temp), 32);
	}

	INLINE bool WriteBits(const uptr data, i32 numBits)
	{
		u8* out = (u8*)data;
		i32 numBitsLeft = numBits;

		// Bounds checking..
		if ((GetNumBitsWritten() + numBits) > m_DataBits)
		{
			SetOverflowed();
			return false;
		}

		// !! speed!! need fast paths
		// write remaining bytes
		while (numBitsLeft >= 8)
		{
			WriteUBitLong(*out, 8, false);
			++out;
			numBitsLeft -= 8;
		}

		// write remaining bits
		if (numBitsLeft)
			WriteUBitLong(*out, numBitsLeft, false);

		return !IsOverflowed();
	}

	INLINE bool WriteBytes(const uptr data, i32 numBytes) { return WriteBits(data, numBytes << 3); }

	INLINE i32 GetNumBitsWritten() { return (32 - m_OutBitsLeft) + (32 * (m_DataOut - m_Data)); }

	INLINE i32 GetNumBytesWritten() { return (GetNumBitsWritten() + 7) >> 3; }

	INLINE void WriteChar(i32 val) { WriteSBitLong(val, sizeof(char) << 3); }

	INLINE void WriteByte(i32 val) { WriteUBitLong(val, sizeof(unsigned char) << 3, false); }

	INLINE void WriteShort(i32 val) { WriteSBitLong(val, sizeof(short) << 3); }

	INLINE void WriteWord(i32 val) { WriteUBitLong(val, sizeof(unsigned short) << 3); }

	INLINE bool WriteString(const char* str)
	{
		if (str)
			while (*str)
				WriteChar(*(str++));

		WriteChar(0);

		return !IsOverflowed();
	}

	INLINE void WriteLongLong(i64 val)
	{
		u32* pLongs = (u32*)&val;

		// Insert the two DWORDS according to network endian
		const short endianIndex = 0x0100;
		u8* idx = (u8*)&endianIndex;

		WriteUBitLong(pLongs[*idx++], sizeof(i32) << 3);
		WriteUBitLong(pLongs[*idx], sizeof(i32) << 3);
	}

	/*INLINE void WriteBitCoord(const float f) {
		i32 signbit = (f <= -COORD_RESOLUTION);
		i32 intval = (i32)abs(f);
		i32 fractval = abs((i32)(f * COORD_DENOMINATOR)) & (COORD_DENOMINATOR - 1);

		// Send the bit flags that indicate whether we have an integer part and/or a fraction part.
		WriteOneBit(intval);
		WriteOneBit(fractval);

		if (intval || fractval) {
			// Send the sign bit
			WriteOneBit(signbit);

			// Send the integer if we have one.
			if (intval) {
				// Adjust the integers from [1..MAX_COORD_VALUE] to [0..MAX_COORD_VALUE-1]
				intval--;
				WriteUBitLong((u32)intval, COORD_INTEGER_BITS);
			}

			// Send the fraction if we have one
			if (fractval) {
				WriteUBitLong((u32)fractval, COORD_FRACTIONAL_BITS);
			}
		}
	}

	INLINE void WriteBitCoordMP(const float f) {
		i32 signbit = (f <= -COORD_RESOLUTION);
		i32 intval = (i32)abs(f);
		i32 fractval = (abs((i32)(f * COORD_DENOMINATOR)) & (COORD_DENOMINATOR - 1));

		bool bInBounds = intval < (1 << COORD_INTEGER_BITS_MP);

		WriteOneBit(bInBounds);

		// Send the sign bit
		WriteOneBit(intval);

		if (intval) {
			WriteOneBit(signbit);

			// Send the integer if we have one.
			// Adjust the integers from [1..MAX_COORD_VALUE] to [0..MAX_COORD_VALUE-1]
			intval--;

			if (bInBounds)
				WriteUBitLong((u32)intval, COORD_INTEGER_BITS_MP);
			else
				WriteUBitLong((u32)intval, COORD_INTEGER_BITS);
		}
	}

	INLINE void WriteBitCellCoord(const float f, int bits, EBitCoordType coordType) {
		bool bIntegral = (coordType == kCW_Integral);
		bool bLowPrecision = (coordType == kCW_LowPrecision);

		i32 intval = (i32)abs(f);
		i32 fractval = bLowPrecision ? (abs((i32)(f * COORD_DENOMINATOR_LOWPRECISION)) & (COORD_DENOMINATOR_LOWPRECISION - 1)) :
	(abs((i32)(f * COORD_DENOMINATOR)) & (COORD_DENOMINATOR - 1));

		if (bIntegral)
			WriteUBitLong((u32)intval, bits);
		else {
			WriteUBitLong((u32)intval, bits);
			WriteUBitLong((u32)fractval, bLowPrecision ? COORD_FRACTIONAL_BITS_MP_LOWPRECISION : COORD_FRACTIONAL_BITS);
		}
	}*/

	INLINE void SeekToBit(int bit)
	{
		TempFlush();

		m_DataOut = m_Data + (bit / 32);
		m_OutBufWord = LoadLittleDWord(m_DataOut, 0);
		m_OutBitsLeft = 32 - (bit & 31);
	}

	/*INLINE void WriteBitVec3Coord(const Vector& fa) {
		i32 xflag, yflag, zflag;

		xflag = (fa[0] >= COORD_RESOLUTION) || (fa[0] <= -COORD_RESOLUTION);
		yflag = (fa[1] >= COORD_RESOLUTION) || (fa[1] <= -COORD_RESOLUTION);
		zflag = (fa[2] >= COORD_RESOLUTION) || (fa[2] <= -COORD_RESOLUTION);

		WriteOneBit(xflag);
		WriteOneBit(yflag);
		WriteOneBit(zflag);

		if (xflag)
			WriteBitCoord(fa[0]);
		if (yflag)
			WriteBitCoord(fa[1]);
		if (zflag)
			WriteBitCoord(fa[2]);
	}

	INLINE void WriteBitNormal(float f) {
		i32 signbit = (f <= -NORMAL_RESOLUTION);

		// NOTE: Since +/-1 are valid values for a normal, I'm going to encode that as all ones
		u32 fractval = abs((i32)(f * NORMAL_DENOMINATOR));

		// clamp..
		if (fractval > NORMAL_DENOMINATOR)
			fractval = NORMAL_DENOMINATOR;

		// Send the sign bit
		WriteOneBit(signbit);

		// Send the fractional component
		WriteUBitLong(fractval, NORMAL_FRACTIONAL_BITS);
	}

	INLINE void WriteBitVec3Normal(const Vector& fa) {
		i32 xflag, yflag;

		xflag = (fa[0] >= NORMAL_RESOLUTION) || (fa[0] <= -NORMAL_RESOLUTION);
		yflag = (fa[1] >= NORMAL_RESOLUTION) || (fa[1] <= -NORMAL_RESOLUTION);

		WriteOneBit(xflag);
		WriteOneBit(yflag);

		if (xflag)
			WriteBitNormal(fa[0]);
		if (yflag)
			WriteBitNormal(fa[1]);

		// Write z sign bit
		i32 signbit = (fa[2] <= -NORMAL_RESOLUTION);
		WriteOneBit(signbit);
	}*/

	INLINE void WriteBitAngle(float angle, int numBits)
	{
		u32 shift = GetBitForBitnum(numBits);
		u32 mask = shift - 1;

		i32 d = (i32)((angle / 360.0) * shift);
		d &= mask;

		WriteUBitLong((u32)d, numBits);
	}

	INLINE bool WriteBitsFromBuffer(BFRead* in, int numBits)
	{
		while (numBits > 32)
		{
			WriteUBitLong(in->ReadUBitLong(32), 32);
			numBits -= 32;
		}

		WriteUBitLong(in->ReadUBitLong(numBits), numBits);
		return !IsOverflowed() && !in->IsOverflowed();
	}

	/*INLINE void WriteBitAngles(const QAngle& fa) {
		// FIXME:
		Vector tmp(fa.x, fa.y, fa.z);
		WriteBitVec3Coord(tmp);
	}*/

  private:
	size_t m_DataBits = 0;
	size_t m_DataBytes = 0;

	u32 m_OutBufWord = 0;
	u32 m_OutBitsLeft = 32;

	u32* m_DataOut = nullptr;
	u32* m_DataEnd = nullptr;
	u32* m_Data = nullptr;

	bool m_Flushed = false; // :flushed:
};

#undef INLINE