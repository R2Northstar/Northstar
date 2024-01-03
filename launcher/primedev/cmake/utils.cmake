# Check if a dependency exist before trying to init git submodules
function(check_init_submodule path)
    file(
        GLOB
        DIR_CONTENT
        "${path}/*"
        )
    list(
        LENGTH
        DIR_CONTENT
        CONTENT_COUNT
        )
    if(CONTENT_COUNT
       EQUAL
       0
       )
        if(NOT
           EXISTS
           "${PROJECT_SOURCE_DIR}/.git"
           )
            message(FATAL_ERROR "Failed to find third party dependency in '${path}'")
        endif()

        find_package(Git QUIET)
        if(NOT Git_FOUND)
            message(FATAL_ERROR "Failed to find Git, third party dependency could not be setup at `${path}")
        endif()

        message(STATUS "Setting up dependencies as git submodules")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMOD_RESULT
            )

        if(NOT
           GIT_SUBMOD_RESULT
           EQUAL
           "0"
           )
            message(FATAL_ERROR "Initializing Git submodules failed with ${GIT_SUBMOD_RESULT}")
        endif()
    endif()
endfunction()
