#include "pakfile.h"

#define IALIGN(a, b) (((a) + ((b)-1)) & ~((b)-1))

bool PakFile::IsValid()
{
	std::map<int, size_t> segmentSizes;
	size_t segmentRequiredAlignmentPadding[PAK_MAX_SEGMENTS] = {};
	size_t segmentNextPageOffsets[PAK_MAX_SEGMENTS] = {};

	for (size_t i = 0; i < header.pageCount; ++i)
	{
		auto pageHdr = headerFields.pageInfo[i];
		segmentSizes[pageHdr.segIdx] += pageHdr.dataSize;

		const size_t pageOffsetAligned = IALIGN(segmentNextPageOffsets[pageHdr.segIdx], pageHdr.align);
		segmentRequiredAlignmentPadding[pageHdr.segIdx] += pageOffsetAligned - segmentNextPageOffsets[pageHdr.segIdx];

		segmentNextPageOffsets[pageHdr.segIdx] = pageOffsetAligned + pageHdr.dataSize;
	}

	for (size_t segmentIdx = 0; segmentIdx < header.virtualSegmentCount; ++segmentIdx)
	{
		auto segmentHdr = headerFields.virtualSegments[segmentIdx];
		const size_t actualSegmentAlignmentPadding = segmentHdr.size - segmentSizes.at(segmentIdx);

		if (actualSegmentAlignmentPadding < segmentRequiredAlignmentPadding[segmentIdx])
			return false;
	}

	return true;
}
