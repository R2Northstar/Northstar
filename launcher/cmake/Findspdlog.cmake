
if(NOT spdlog_FOUND)
	check_init_submodule(${PROJECT_SOURCE_DIR}/thirdparty/spdlog)

	add_subdirectory(${PROJECT_SOURCE_DIR}/thirdparty/spdlog spdlog)
	set(spdlog_FOUND 1 PARENT_SCOPE)
endif()

