cmake_minimum_required(VERSION 3.15)

project(Northstar CXX ASM_MASM)

# Language specs
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_VS_PLATFORM_TOOLSET v143)

# This determines the real binary root directory
set(NS_BINARY_DIR ${CMAKE_BINARY_DIR}/game)
# NOTE [Fifty]: Visual studio deems Build root with the value "${projectDir}"
# in CMakeSettings.json as invalid and defaults to using a temporary dir
# somewhere in %USER%/CMakeBuilds. To combat this we set it to "${projectDir}/build"
# and then link binaries in ${CMAKE_BINARY_DIR}/game. This means you can copy your
# game into ${CMAKE_BINARY_DIR}/game without it being cluttered up by cmake files.

message("NS: Building to ${NS_BINARY_DIR}")

# Targets
add_subdirectory(loader_wsock32_proxy)
add_subdirectory(NorthstarDLL)
add_subdirectory(NorthstarLauncher)
