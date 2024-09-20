# HTTP and JSON

As of v1.12.0, you can now make HTTP requests from Squirrel scripts.
HTTP requests allow you to query online APIs, send, retrieve data and much more.

This is particularly useful for custom APIs you might want to build for your servers, for instance if you want to wrap
a database with an API so that your servers can save player stats.

!!! warning

    For security reasons, private network hosts, such as `localhost` or `192.168.1.106` are blocked by default, meaning you cannot make HTTP requests to them.
    This includes a blanket ban on IPv6 hosts.

    You are also limited to `HTTP` and `HTTPS` for protocols. Any other protocols will prevent the request from being made.

## Launch Arguments

There are a few launch arguments you may use to bypass some of the limitations, or outright disable HTTP requests.

These should be applied to your client or server's launch commandline.

|Name|Description|
|---|---|
|`-allowlocalhttp`| Disables private network checks for HTTP requests, allowing any IPv4 and IPv6 host to be used.|
|`-disablehttprequests`| Disables HTTP requests. Any attempts at making requests will fail.|
|`-disablehttpssl`| Disables SSL verifications, useful when the host's SSL certificate is invalid, and insecure HTTP cannot be used.|


## HTTP API

This section documents all the available functions, structs and enums used to make HTTP request in Squirrel scripts.

!!! warning

    HTTP requests are multithreaded, as such they will run in the background until completion, whether successful or failed.
    Be mindful of how many requests you make at a time, as you may potentially get ratelimited or blacklisted by the remote host.
    Use the callbacks to execute code when a request has completed.

### Data

The HTTP system uses a few enums and structs for requests and their callbacks.


!!! cpp-enum "enum HttpRequestMethod"

    Contains the different allowed methods for a HTTP request. Please work.

    !!! cpp-member "GET = 0"

        Uses the `GET` HTTP method for the request.

    !!! cpp-member "POST = 1"

        Uses the `POST` HTTP method for the request.

    !!! cpp-member "HEAD = 2"

        Uses the `HEAD` HTTP method for the request.

    !!! cpp-member "PUT = 3"

        Uses the `PUT` HTTP method for the request.

    !!! cpp-member "DELETE = 4"

        Uses the `DELETE` HTTP method for the request.

    !!! cpp-member "PATCH = 5"

        Uses the `PATCH` HTTP method for the request.

    !!! cpp-member "OPTIONS = 6"

        Uses the `OPTIONS` HTTP method for the request.



!!! cpp-struct "struct HttpRequest"

    Contains the settings for a HTTP request. This is used for the more flexible `NSHttpRequest` function.

    !!! cpp-var "(HttpRequestMethod) int method"

        HTTP method used for this HTTP request.

    !!! cpp-var "string url"

        Base URL of this HTTP request.

    !!! cpp-var "table< string, array< string > > headers"

        Headers used for this HTTP request. Some may get overridden or ignored.

    !!! cpp-var "table< string, array< string > > queryParameters"

        Query parameters for this HTTP request.

    !!! cpp-var "string contentType = "application/json; charset=utf-8""

        The content type of this HTTP request. Defaults to application/json & UTF-8 charset.

    !!! cpp-var "string body"

        The body of this HTTP request. If set, will override queryParameters.

    !!! cpp-var "int timeout = 60"

        The timeout for this HTTP request in seconds. Clamped between 1 and 60.

    !!! cpp-var "string userAgent"

        If set, the override to use for the User-Agent header.


!!! warning

    Only `POST` requests can send a body to the remote end. You may only choose to send a body, or query parameters.
    Having both will give priority to the body and clear the parameters.



!!! cpp-struct "struct HttpRequestResponse"

    Contains the response from the remote host for a successful HTTP request.

    !!! cpp-var "int statusCode"

        The status code returned by the remote the call was made to.

    !!! cpp-var "string body"

        The body of the response.

    !!! cpp-var "string rawHeaders"

        The raw headers returned by the remote.

    !!! cpp-var "table< string, array< string > > headers"

        A key -> values table of headers returned by the remote.



!!! cpp-struct "struct HttpRequestFailure"

    Contains the failure code and message when Northstar fails to make a HTTP request.

    !!! cpp-var "int errorCode"

        The status code returned by the remote the call was made to.

    !!! cpp-var "string errorMessage"

        The reason why this HTTP request failed.


### Functions

!!! warning

    Your mod needs to be load priority 1 or above to use `HttpRequest` and `HttpRequestResponse` in your script.


!!! cpp-function "bool NSHttpRequest( HttpRequest requestParameters, void functionref( HttpRequestResponse ) onSuccess = null, void functionref( HttpRequestFailure ) onFailure = null )"

    Launches a HTTP request with the given request data.
    This function is async, and the provided callbacks will be called when it is completed, if any.

    **Parameters:**

    - `HttpRequest requestParameters` - The parameters to use for this request.
    - `[OPTIONAL] void functionref( HttpRequestResponse ) onSuccess` - The callback to execute if the request is successful.
    - `[OPTIONAL] void functionref( HttpRequestFailure ) onFailure` - The callback to execute if the request has failed.

    **Returns:**

    - Whether or not the request has been successfully started.

    **Example:**

    Below is a working example of an HTTP request for a mod.

    As you can see, you can either use named functions for the callbacks, or create lambdas.
    Lambdas are particularly useful as they let you capture local variables of the functions to re-use later
    such as `callback` in this example.

    ```squirrel
        HttpRequest request
        request.method = HttpRequestMethod.GET
        request.url = "https://my.spyglass.api/sanctions/get_by_id"
        request.queryParameters[ "id" ] <- [ id.tostring() ]

        void functionref( HttpRequestResponse ) onSuccess = void function ( HttpRequestResponse response ) : ( callback )
        {
            SpyglassApi_OnQuerySanctionByIdSuccessful( response, callback )
        }

        void functionref( HttpRequestFailure ) onFailure = void function ( HttpRequestFailure failure ) : ( callback )
        {
            SpyglassApi_OnQuerySanctionByIdFailed( failure, callback )
        }

        return NSHttpRequest( request, onSuccess, onFailure )
    ```




!!! cpp-function "bool NSHttpGet( string url, table< string, array< string > > queryParameters = {}, void functionref( HttpRequestResponse ) onSuccess = null, void functionref( HttpRequestFailure ) onFailure = null  )"

    Launches an HTTP GET request at the specified URL with the given query parameters.
    Shortcut wrapper of NSHttpRequest().
    This function is async, and the provided callbacks will be called when it is completed, if any.

    **Parameters:**

    - `string url` - The url to make the HTTP request at.
    - `[OPTIONAL] table< string, array< string > > queryParameters` - A table of key value parameters to insert in the url.
    - `[OPTIONAL] void functionref( HttpRequestResponse ) onSuccess` - The callback to execute if the request is successful.
    - `[OPTIONAL] void functionref( HttpRequestFailure ) onFailure` - The callback to execute if the request has failed.

    **Returns:**

    - Whether or not the request has been successfully started.

    **Example:**

    This is the same example as NSHttpRequest()'s example. However, it uses this function instead.

    ```squirrel
        table<string, array<string> > params
        params[ "id" ] <- [ id.tostring() ]

        void functionref( HttpRequestResponse ) onSuccess = void function ( HttpRequestResponse response ) : ( callback )
        {
            SpyglassApi_OnQuerySanctionByIdSuccessful( response, callback )
        }

        void functionref( HttpRequestFailure ) onFailure = void function ( HttpRequestFailure failure ) : ( callback )
        {
            SpyglassApi_OnQuerySanctionByIdFailed( failure, callback )
        }

        return NSHttpGet( "https://my.spyglass.api/sanctions/get_by_id", params, onSuccess, onFailure )
    ```



!!! cpp-function "bool NSHttpPostQuery( string url, table< string, array< string > > queryParameters, void functionref( HttpRequestResponse ) onSuccess = null, void functionref( HttpRequestFailure ) onFailure = null )"

    Launches an HTTP POST request at the specified URL with the given query parameters.
    Shortcut wrapper of NSHttpRequest().
    This function is async, and the provided callbacks will be called when it is completed, if any.

    **Parameters:**

    - `string url` - The url to make the HTTP request at.
    - `[OPTIONAL] table< string, array< string > > queryParameters` - A table of key value parameters to insert in the url.
    - `[OPTIONAL] void functionref( HttpRequestResponse ) onSuccess` - The callback to execute if the request is successful.
    - `[OPTIONAL] void functionref( HttpRequestFailure ) onFailure` - The callback to execute if the request has failed.

    **Returns:**

    - Whether or not the request has been successfully started.



!!! cpp-function "bool NSHttpPostBody( string url, string body, void functionref( HttpRequestResponse ) onSuccess = null, void functionref( HttpRequestFailure ) onFailure = null )"

    Launches an HTTP POST request at the specified URL with the given body.
    Shortcut wrapper of NSHttpRequest().
    This function is async, and the provided callbacks will be called when it is completed, if any.

    This is the more interesting POST function, as you can use it to convert a table into JSON and "POST" it to the remote server.

    **Parameters:**

    - `string url` - The url to make the HTTP request at.
    - `string body` - The body to send with the request. Expects JSON by default.
    - `[OPTIONAL] void functionref( HttpRequestResponse ) onSuccess` - The callback to execute if the request is successful.
    - `[OPTIONAL] void functionref( HttpRequestFailure ) onFailure` - The callback to execute if the request has failed.

    **Returns:**

    - Whether or not the request has been successfully started.

    **Example:**

    In this example, we'll convert a table to JSON, and send it over to a web API.

    ```squirrel
        table myData = {}
        myData[ "uid" ] <- player.GetUID()
        myData[ "username" ] <- player.GetPlayerName()
        myData[ "isBot" ] <- player.IsBot().tostring()

        string json = EncodeJSON( myData )
        if ( NSHttpPostBody( "https://api.stats.tf/player/connect", json ) )
        {
            printt( "Successfully attempted to upload player connection stats to API." )
        }
    ```




!!! cpp-function "bool NSIsSuccessHttpCode( int statusCode )"

    Checks whether or not the given HTTP status code is considered a "success" code.

    This is true for status codes between 200 and 299.

    **Parameters:**

    - `int statusCode` - The status code to verify.

    **Returns:**

    - Whether or not the given status code is considered successful.



## JSON API {#json_overview}

!!! warning

    The JSON parser currently supports the following types for values: `string`, `integer`, `float`, `bool`, `table`, and `array`.

    Tables and arrays can only hold supported types. Unsupported types will be ignored. Keys can only be strings.

    The JSON parser currently does not support keys holding `null` values, and simply won't include them in decoded tables or encoded JSON strings.




!!! cpp-function "table DecodeJSON( string json, bool fatalParseErrors = false )"


    Converts a JSON string to a Squirrel table.

    **Parameters:**

    - `string json` - The JSON string to decode into a table.
    - `[OPTIONAL] bool fatalParseErrors` - Whether or not parsing errors should throw a fatal script error. Default to false.

    **Returns:**

    - The table decoded from the JSON string on success, or an empty table `{}` on parse failure (if fatalParseErrors is false).




!!! cpp-function "string EncodeJSON( table data )"

    Converts a Squirrel table to a JSON string.

    **Parameters:**

    - `table data` - The table to encode to a JSON string.

    **Returns:**

    - The JSON string parsed from the Squirrel table.

Paired with [HTTP and JSON](httprequests.md) , this allows you to send and retrieve JSON data from external sources.
