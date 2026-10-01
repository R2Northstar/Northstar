if(NOT minhook_FOUND)
    check_init_submodule(${PROJECT_SOURCE_DIR}/primedev/thirdparty/minhook)

    add_subdirectory(${PROJECT_SOURCE_DIR}/primedev/thirdparty/minhook minhook)
    set(minhook_FOUND 1)
endif()
