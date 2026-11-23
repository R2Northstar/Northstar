#include "pakfile.h"

#include <limits>

static bool IsPositivePowerOfTwo(const uint32_t value)
{
	return value != 0 && (value & (value - 1)) == 0;
}

static bool AlignAndAdvance(size_t& cursor, const size_t alignment, const size_t dataSize)
{
	constexpr size_t maxSize = (std::numeric_limits<size_t>::max)();
	if (cursor > maxSize - (alignment - 1))
		return false;

	const size_t aligned = (cursor + alignment - 1) & ~(alignment - 1);
	if (dataSize > maxSize - aligned)
		return false;

	cursor = aligned + dataSize;
	return true;
}

bool PakFile::IsValid()
{
	if (header.virtualSegmentCount > PAK_MAX_SEGMENTS || !headerFields.virtualSegments || !headerFields.pageInfo)
		return false;

	size_t segmentNextPageOffsets[PAK_MAX_SEGMENTS] = {};

	for (size_t segmentIdx = 0; segmentIdx < header.virtualSegmentCount; ++segmentIdx)
	{
		if (!IsPositivePowerOfTwo(headerFields.virtualSegments[segmentIdx].align))
			return false;
	}

	for (size_t i = 0; i < header.pageCount; ++i)
	{
		const auto& pageHdr = headerFields.pageInfo[i];
		if (pageHdr.segIdx >= header.virtualSegmentCount || !IsPositivePowerOfTwo(pageHdr.align))
			return false;

		const auto& segmentHdr = headerFields.virtualSegments[pageHdr.segIdx];
		const uint32_t bufferType = segmentHdr.flags & (PAK_SLAB_BUFFER_TYPES - 1);
		if (bufferType != 0 && pageHdr.align > segmentHdr.align)
			return false;

		if (!AlignAndAdvance(segmentNextPageOffsets[pageHdr.segIdx], pageHdr.align, pageHdr.dataSize))
			return false;
	}

	for (size_t segmentIdx = 0; segmentIdx < header.virtualSegmentCount; ++segmentIdx)
	{
		if (headerFields.virtualSegments[segmentIdx].size < segmentNextPageOffsets[segmentIdx])
			return false;
	}

	return true;
}
