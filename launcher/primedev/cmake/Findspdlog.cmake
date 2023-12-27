
if(NOT spdlog_FOUND)
	check_init_submodule(${PROJECT_SOURCE_DIR}/primedev/thirdparty/spdlog)

	add_subdirectory(${PROJECT_SOURCE_DIR}/primedev/thirdparty/spdlog spdlog)
	set(spdlog_FOUND 1)
endif()
