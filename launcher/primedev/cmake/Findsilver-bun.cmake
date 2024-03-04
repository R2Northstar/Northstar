if(NOT silver-bun_FOUND)
    check_init_submodule(${PROJECT_SOURCE_DIR}/primedev/thirdparty/silver-bun)

    add_subdirectory(${PROJECT_SOURCE_DIR}/primedev/thirdparty/silver-bun silver-bun)
    set(silver-bun_FOUND
        1
        PARENT_SCOPE
        )
endif()
