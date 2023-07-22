
if(NOT minhook_FOUND)
	check_init_submodule(${PROJECT_SOURCE_DIR}/thirdparty/minhook)

	add_subdirectory(${PROJECT_SOURCE_DIR}/thirdparty/minhook minhook)
	set(minhook_FOUND 1 PARENT_SCOPE)
endif()

