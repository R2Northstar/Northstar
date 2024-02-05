#pragma once

// [Fifty]: Taken from https://github.com/ASpoonPlaysGames/r2recast

#include "core/math/vector.h"

struct dtMeshHeader;
struct dtMeshTile;
struct dtPoly;
struct dtBVNode;
struct dtLink;

typedef unsigned int dtPolyRef;

/// The maximum number of vertices per navigation polygon.
/// @ingroup detour
static const int DT_VERTS_PER_POLYGON = 6;

/// Flags representing the type of a navigation mesh polygon.
enum dtPolyTypes
{
	/// The polygon is a standard convex polygon that is part of the surface of the mesh.
	DT_POLYTYPE_GROUND = 0,
	/// The polygon is an off-mesh connection consisting of two vertices.
	DT_POLYTYPE_OFFMESH_CONNECTION = 1,
};

/// Configuration parameters used to define multi-tile navigation meshes.
/// The values are used to allocate space during the initialization of a navigation mesh.
/// @see dtNavMesh::init()
/// @ingroup detour
struct dtNavMeshParams
{
	float orig[3]; ///< The world space origin of the navigation mesh's tile space. [(x, y, z)]
	float tileWidth; ///< The width of each tile. (Along the x-axis.)
	float tileHeight; ///< The height of each tile. (Along the z-axis.)
	int maxTiles; ///< The maximum number of tiles the navigation mesh can contain. This and maxPolys are used to calculate how many bits
				  ///< are needed to identify tiles and polygons uniquely.
	int maxPolys; ///< The maximum number of polygons each tile can contain. This and maxTiles are used to calculate how many bits are
				  ///< needed to identify tiles and polygons uniquely.
	//
	//// i hate this
	int disjointPolyGroupCount = 0;
	int reachabilityTableSize = 0;
	int reachabilityTableCount = 0;
};

/// Defines an navigation mesh off-mesh connection within a dtMeshTile object.
/// An off-mesh connection is a user defined traversable connection made up to two vertices.
struct dtOffMeshConnection
{
	/// The endpoints of the connection.
	Vector3 origin;
	Vector3 dest;

	/// The radius of the endpoints. [Limit: >= 0]
	float rad;

	/// The polygon reference of the connection within the tile.
	unsigned short poly;

	/// Link flags.
	/// @note These are not the connection's user defined flags. Those are assigned via the
	/// connection's dtPoly definition. These are link flags used for internal purposes.
	unsigned char flags;

	/// End point side.
	unsigned char side;

	/// The id of the offmesh connection. (User assigned when the navigation mesh is built.)
	unsigned int userId;

	float unk[3];
	float another_unk;
};

/// A navigation mesh based on tiles of convex polygons.
/// @ingroup detour
class dtNavMesh
{
public:
	dtMeshTile** m_posLookup; ///< Tile hash lookup.
	dtMeshTile* m_nextFree; ///< Freelist of tiles.
	dtMeshTile* m_tiles; ///< List of tiles.

	void* disjointPolyGroup;
	int** reachabilityTable;

	__int64 unk;
	dtNavMeshParams m_params; ///< Current initialization params. TODO: do not store this info twice.
	float m_orig[3]; ///< Origin of the tile (0,0)
	float m_tileWidth, m_tileHight; ///< Dimensions of each tile.
	int m_pad;
	int m_maxTiles; ///< Max number of tiles.

	int m_tileLutSize; ///< Tile hash lookup size (must be pot).
	int m_tileLutMask; ///< Tile hash lookup mask.

	int m_saltBits; ///< Number of salt bits in the tile ID.
	int m_tileBits; ///< Number of tile bits in the tile ID.
	int m_polyBits; ///< Number of poly bits in the tile ID.
};

/// Defines the location of detail sub-mesh data within a dtMeshTile.
struct dtPolyDetail
{
	unsigned int vertBase; ///< The offset of the vertices in the dtMeshTile::detailVerts array.
	unsigned int triBase; ///< The offset of the triangles in the dtMeshTile::detailTris array.
	unsigned char vertCount; ///< The number of vertices in the sub-mesh.
	unsigned char triCount; ///< The number of triangles in the sub-mesh.
};

/// Defines a navigation mesh tile.
/// @ingroup detour
struct dtMeshTile
{
	int salt; ///< Counter describing modifications to the tile.
	unsigned int linksFreeList; ///< Index to the next free link.
	dtMeshHeader* header; ///< The tile header.
	dtPoly* polys; ///< The tile polygons. [Size: dtMeshHeader::polyCount]
	void* unkPolyThing;
	float* verts; ///< The tile vertices. [Size: dtMeshHeader::vertCount]
	dtLink* links; ///< The tile links. [Size: dtMeshHeader::maxLinkCount]
	dtPolyDetail* detailMeshes; ///< The tile's detail sub-meshes. [Size: dtMeshHeader::detailMeshCount]

	/// The detail mesh's unique vertices. [(x, y, z) * dtMeshHeader::detailVertCount]
	float* detailVerts;

	/// The detail mesh's triangles. [(vertA, vertB, vertC, triFlags) * dtMeshHeader::detailTriCount].
	/// See dtDetailTriEdgeFlags and dtGetDetailTriEdgeFlags.
	unsigned char* detailTris;

	/// The tile bounding volume nodes. [Size: dtMeshHeader::bvNodeCount]
	/// (Will be null if bounding volumes are disabled.)
	dtBVNode* bvTree;

	dtOffMeshConnection* offMeshConnections; ///< The tile off-mesh connections. [Size: dtMeshHeader::offMeshConCount]
	void* data; ///< The tile data. (Not directly accessed under normal situations.)
	int dataSize; ///< Size of the tile data.
	int flags; ///< Tile flags. (See: #dtTileFlags)
	dtMeshTile* next; ///< The next free tile, or the next tile in the spatial grid.
	__int64 unk;
};

/// Provides high level information related to a dtMeshTile object.
/// @ingroup detour
struct dtMeshHeader
{
	int magic; ///< Tile magic number. (Used to identify the data format.)
	int version; ///< Tile data format version number.
	int x; ///< The x-position of the tile within the dtNavMesh tile grid. (x, y, layer)
	int y; ///< The y-position of the tile within the dtNavMesh tile grid. (x, y, layer)
	int layer; ///< The layer of the tile within the dtNavMesh tile grid. (x, y, layer)
	unsigned int userId; ///< The user defined id of the tile.
	int polyCount; ///< The number of polygons in the tile.
	int sth_per_poly;
	int vertCount; ///< The number of vertices in the tile.
	int maxLinkCount; ///< The number of allocated links.

	int detailMeshCount;

	/// The number of unique vertices in the detail mesh. (In addition to the polygon vertices.)
	int detailVertCount;

	int detailTriCount; ///< The number of triangles in the detail mesh.
	int bvNodeCount; ///< The number of bounding volume nodes. (Zero if bounding volumes are disabled.)
	int offMeshConCount; ///< The number of off-mesh connections.
	// int unk1;
	int offMeshBase; ///< The index of the first polygon which is an off-mesh connection.

	float walkableHeight; ///< The height of the agents using the tile.
	float walkableRadius; ///< The radius of the agents using the tile.
	float walkableClimb; ///< The maximum climb height of the agents using the tile.
	float bmin[3]; ///< The minimum bounds of the tile's AABB. [(x, y, z)]
	float bmax[3]; ///< The maximum bounds of the tile's AABB. [(x, y, z)]

	/// The bounding volume quantization factor.
	float bvQuantFactor;
};

/// Defines a polygon within a dtMeshTile object.
/// @ingroup detour
struct dtPoly
{
	/// Index to first link in linked list. (Or #DT_NULL_LINK if there is no link.)
	unsigned int firstLink;

	/// The indices of the polygon's vertices.
	/// The actual vertices are located in dtMeshTile::verts.
	unsigned short verts[DT_VERTS_PER_POLYGON];

	/// Packed data representing neighbor polygons references and flags for each edge.
	unsigned short neis[DT_VERTS_PER_POLYGON];

	/// The user defined polygon flags.
	unsigned short flags;

	/// The number of vertices in the polygon.
	unsigned char vertCount;

	/// The bit packed area id and polygon type.
	/// @note Use the structure's set and get methods to acess this value.
	unsigned char areaAndtype;

	unsigned short disjointSetId;
	unsigned short unk; // IDK but looks filled
	Vector3 org; //

	/// Sets the user defined area id. [Limit: < #DT_MAX_AREAS]
	inline void setArea(unsigned char a)
	{
		areaAndtype = (areaAndtype & 0xc0) | (a & 0x3f);
	}

	/// Sets the polygon type. (See: #dtPolyTypes.)
	inline void setType(unsigned char t)
	{
		areaAndtype = (areaAndtype & 0x3f) | (t << 6);
	}

	/// Gets the user defined area id.
	inline unsigned char getArea() const
	{
		return areaAndtype & 0x3f;
	}

	/// Gets the polygon type. (See: #dtPolyTypes)
	inline unsigned char getType() const
	{
		return areaAndtype >> 6;
	}
};

/// Defines a link between polygons.
/// @note This structure is rarely if ever used by the end user.
/// @see dtMeshTile
struct dtLink
{
	dtPolyRef ref; ///< Neighbour reference. (The neighbor that is linked to.)
	unsigned int next; ///< Index of the next link.
	unsigned char edge; ///< Index of the polygon edge that owns this link.
	unsigned char side; ///< If a boundary link, defines on which side the link is.
	unsigned char bmin; ///< If a boundary link, defines the minimum sub-edge area.
	unsigned char bmax; ///< If a boundary link, defines the maximum sub-edge area.
	unsigned char jumpType;
	unsigned char otherUnk;
	unsigned short reverseLinkIndex;
};

/// Bounding volume node.
/// @note This structure is rarely if ever used by the end user.
/// @see dtMeshTile
struct dtBVNode
{
	unsigned short bmin[3]; ///< Minimum bounds of the node's AABB. [(x, y, z)]
	unsigned short bmax[3]; ///< Maximum bounds of the node's AABB. [(x, y, z)]
	int i; ///< The node's index. (Negative for escape sequence.)
};

inline dtNavMesh** g_pNavMesh = nullptr;
