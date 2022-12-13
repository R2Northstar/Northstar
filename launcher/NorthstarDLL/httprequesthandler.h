#pragma once

#include "pch.h"

enum class ScriptContext;

// These definitions below should match on the Squirrel side so we can easily pass them along through a function.

/**
 * Allowed methods for an HttpRequest.
 */
namespace HttpRequestMethod
{
	enum Type
	{
		HRM_GET = 0,
		HRM_POST = 1,
		HRM_HEAD = 2,
		HRM_PUT = 3,
		HRM_DELETE = 4,
		HRM_PATCH = 5,
		HRM_OPTIONS = 6,
	};

	/** Returns the HTTP string representation of the given method. */
	inline std::string ToString(HttpRequestMethod::Type method)
	{
		switch (method)
		{
		case HttpRequestMethod::HRM_GET:
			return "GET";
		case HttpRequestMethod::HRM_POST:
			return "POST";
		case HttpRequestMethod::HRM_HEAD:
			return "HEAD";
		case HttpRequestMethod::HRM_PUT:
			return "PUT";
		case HttpRequestMethod::HRM_DELETE:
			return "DELETE";
		case HttpRequestMethod::HRM_PATCH:
			return "PATCH";
		case HttpRequestMethod::HRM_OPTIONS:
			return "OPTIONS";
		default:
			return "INVALID";
		}
	}

	/** Whether or not the given method should be treated like a POST for curlopts. */
	bool UsesCurlPostOptions(HttpRequestMethod::Type method)
	{
		switch (method)
		{
		case HttpRequestMethod::HRM_POST:
		case HttpRequestMethod::HRM_PUT:
		case HttpRequestMethod::HRM_DELETE:
		case HttpRequestMethod::HRM_PATCH:
			return true;
		default:
			return false;
		}
	}

	/** Whether or not the given http request method can have query parameters in the URL. */
	bool CanHaveQueryParameters(HttpRequestMethod::Type method)
	{
		return method == HttpRequestMethod::HRM_GET || UsesCurlPostOptions(method);
	}
}; // namespace HttpRequestMethod

/** Contains data about an http request that has been queued. */
struct HttpRequest
{
	/** Method used for this http request. */
	HttpRequestMethod::Type method;

	/** Base URL of this http request. */
	std::string baseUrl;

	/** Headers used for this http request. Some may get overridden or ignored. */
	std::unordered_map<std::string, std::vector<std::string>> headers;

	/** Query parameters for this http request. */
	std::unordered_map<std::string, std::vector<std::string>> queryParameters;

	/** The content type of this http request. Defaults to text/plain & UTF-8 charset. */
	std::string contentType = "text/plain; charset=utf-8";

	/** The body of this http request. If set, will override queryParameters.*/
	std::string body;

	/** The timeout for the http request, in seconds. Must be between 1 and 60. */
	int timeout;

	/** If set, the override to use for the User-Agent header. */
	std::string userAgent;
};

/**
 * Handles making HTTP requests and sending the responses back to Squirrel.
 */
class HttpRequestHandler
{
  public:
	HttpRequestHandler();

	// Start/Stop the HTTP request handler. Right now this doesn't do much.
	void StartHttpRequestHandler();
	void StopHttpRequestHandler();

	// Whether or not this http request handler is currently running.
	bool IsRunning() const
	{
		return m_bIsHttpRequestHandlerRunning;
	}

	/**
	 * Creates a new thread to execute an HTTP request.
	 * @param requestParameters The parameters to use for this http request.
	 * @returns The handle for the http request being sent, or -1 if the request failed.
	 */
	template <ScriptContext context> int MakeHttpRequest(const HttpRequest& requestParameters);

	/** Registers the HTTP request Squirrel functions for the given script context. */
	template <ScriptContext context> void RegisterSQFuncs();

  private:
	int m_iLastRequestHandle = 0;
	std::atomic_bool m_bIsHttpRequestHandlerRunning = false;
};

extern HttpRequestHandler* g_httpRequestHandler;
