
if(NOT minizip_FOUND)
	check_init_submodule(${PROJECT_SOURCE_DIR}/thirdparty/minizip)

	set(MZ_LZMA OFF CACHE BOOL "Disable LZMA & XZ compression")

	add_subdirectory(${PROJECT_SOURCE_DIR}/thirdparty/minizip minizip)
	set(minizip_FOUND 1 PARENT_SCOPE)
endif()

