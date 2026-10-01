# loader_wsock32_proxy

find_package(minhook REQUIRED)

add_library(
    loader_wsock32_proxy SHARED
    "dllmain.cpp"
    "loader.cpp"
    "loader.h"
    "wsock32.def"
    )

target_link_libraries(
    loader_wsock32_proxy
    PRIVATE minhook
            mswsock.lib
            ws2_32.lib
            shlwapi.lib
            imagehlp.lib
            dbghelp.lib
            kernel32.lib
            user32.lib
            gdi32.lib
            winspool.lib
            comdlg32.lib
            advapi32.lib
            shell32.lib
            ole32.lib
            oleaut32.lib
            uuid.lib
            odbc32.lib
            odbccp32.lib
    )

target_compile_definitions(
    loader_wsock32_proxy
    PRIVATE UNICODE
            _UNICODE
            WIN32_LEAN_AND_MEAN
    )

set_target_properties(
    loader_wsock32_proxy
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${NS_BINARY_DIR}/bin/x64_retail
               OUTPUT_NAME wsock32
               LINK_FLAGS "/MANIFEST:NO /DEBUG"
    )
