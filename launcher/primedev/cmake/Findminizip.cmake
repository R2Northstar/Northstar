if(NOT minizip_FOUND)

    # zlib 1.3.1 had a cmake change that broke stuff, use develop for now where a fix has already been applied
    set(ZLIB_TAG "develop")

    check_init_submodule(${PROJECT_SOURCE_DIR}/primedev/thirdparty/minizip)

    set(MZ_ZLIB
        ON
        CACHE BOOL "Enable ZLIB compression, needed for DEFLATE"
        )
    set(MZ_BZIP2
        OFF
        CACHE BOOL "Disable BZIP2 compression"
        )
    set(MZ_LZMA
        OFF
        CACHE BOOL "Disable LZMA & XZ compression"
        )
    set(MZ_PKCRYPT
        OFF
        CACHE BOOL "Disable PKWARE traditional encryption"
        )
    set(MZ_WZAES
        OFF
        CACHE BOOL "Disable WinZIP AES encryption"
        )
    set(MZ_ZSTD
        OFF
        CACHE BOOL "Disable ZSTD compression"
        )
    set(MZ_SIGNING
        OFF
        CACHE BOOL "Disable zip signing support"
        )

    add_subdirectory(${PROJECT_SOURCE_DIR}/primedev/thirdparty/minizip minizip)
    set(minizip_FOUND
        1
        PARENT_SCOPE
        )
endif()
