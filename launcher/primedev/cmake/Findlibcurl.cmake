

if (NOT libcurl_FOUND)
	check_init_submodule(${PROJECT_SOURCE_DIR}/primedev/thirdparty/libcurl)

	set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries")
	set(BUILD_CURL_EXE OFF CACHE BOOL "Build curl EXE")
	set(HTTP_ONLY ON CACHE BOOL "Only build HTTP and HTTPS")
	set(CURL_ENABLE_SSL ON CACHE BOOL "Enable SSL support")
	set(CURL_USE_OPENSSL OFF CACHE BOOL "Disable OpenSSL")
	set(CURL_USE_LIBSSH2 OFF CACHE BOOL "Disable libSSH2")
	set(CURL_USE_SCHANNEL ON CACHE BOOL "Enable Secure Channel")
	set(CURL_CA_BUNDLE "none" CACHE STRING "Disable CA Bundle")
	set(CURL_CA_PATH "none" CACHE STRING "Disable CA Path")

	add_subdirectory(${PROJECT_SOURCE_DIR}/primedev/thirdparty/libcurl libcurl)
	set(libcurl_FOUND 1 PARENT_SCOPE)
endif()
