# HTTP

HTTP core types for Zig inspired by Rust [http](https://github.com/hyperium/http).

[![Build Status](https://api.travis-ci.org/ducdetronquito/http.svg?branch=master)](https://travis-ci.org/ducdetronquito/http) [![License](https://img.shields.io/badge/license-public%20domain-ff69b4.svg)](https://github.com/ducdetronquito/http#license) [![Requirements](https://img.shields.io/badge/zig-0.6.0-orange)](https://ziglang.org/)


## Usage

Create an HTTP request

```zig
const Request = @import("http").Request;
const std = @import("std");

var request = try Request.builder(std.testing.allocator)
    .get("https://ziglang.org/")
    .header("GOTTA-GO", "FAST")
    .body("");
defer request.deinit();
```

Create an HTTP response

```zig
const Response = @import("http").Request;
const StatusCode = @import("http").StatusCode;
const std = @import("std");

var response = try Response.builder(std.testing.allocator)
    .status(.Ok)
    .header("GOTTA-GO", "FAST")
    .body("");
defer response.deinit();
```

## API Reference

### Structures


#### `Headers`
##### An HTTP header list

```zig
// The default constructor
fn init(allocator: *Allocator) Headers
```

```zig
// Add a header name and value
fn add(self: *Headers, name: []const u8, value: []const u8) !void
```

```zig
// Retrieve the first matching header
fn get(self: *Headers, name: []const u8) ?Header
```

```zig
// Retrieve a list of matching headers
fn list(self: *Headers, name: []const u8) ![]Header
```

```zig
// Retrieve the number of headers
fn len(self: *Headers) usize
```

Header issues are tracked here: [#2](https://github.com/ducdetronquito/http/issues/2)


#### `Request`
##### An HTTP request object produced by the request builder.


```zig
// The default constructor to start building a request
fn builder(allocator: *Allocator) RequestBuilder
```

```zig
// Release the memory allocated by the header map
fn deinit(self: *Request) void
```

```zig
// Returns the request's payload
fn body(self: *Request) []const u8
```

```zig
// Returns the request's header map
fn headers(self: *Request) HeaderMap
```

```zig
// Returns the request's method
fn method(self: *Request) Method
```

```zig
// Returns the request's URI
fn uri(self: *Request) Uri
```

```zig
// Returns the request's protocol version
fn version(self: *Request) Version
```

#### `RequestBuilder`
##### The request builder.

```zig
// The default constructor
default(allocator: *Allocator) RequestBuilder
```

```zig
// Release the memory allocated by the header map
fn deinit(self: *RequestBuilder) void
```

```zig
// Set the request's payload.
// This function returns the final request objet or a potential error
// collected during the build steps
fn body(self: *RequestBuilder, value: []const u8) RequestError!Request
```

```zig
// Shortcut to define a CONNECT request to the provided URI
fn connect(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a DELETE request to the provided URI
fn delete(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a GET request to the provided URI
fn get(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define an HEAD request to the provided URI
fn head(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Set a request header name and value
fn header(self: *RequestBuilder, name: []const u8, value: []const u8) *RequestBuilder
```

```zig
// Set the request's method
fn method(self: *RequestBuilder, value: Method) *RequestBuilder
```

```zig
// Shortcut to define an OPTIONS request to the provided URI
fn options(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a PATCH request to the provided URI
fn patch(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a POST request to the provided URI
fn post(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a PUT request to the provided URI
fn put(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Shortcut to define a TRACE request to the provided URI
fn trace(self: *RequestBuilder, _uri: []const u8) *RequestBuilder
```

```zig
// Set the request's URI
fn uri(self: *RequestBuilder, value: []const u8) *RequestBuilder
```

```zig
// Set the request's protocol version
fn version(self: *RequestBuilder, value: Version) *RequestBuilder
```

#### `Response`
##### An HTTP response object produced by the response builder.


```zig
// The default constructor to start building a response
fn builder(allocator: *Allocator) ResponseBuilder
```

```zig
// Release the memory allocated by the header map
fn deinit(self: *Response) void
```

```zig
// Returns the response's payload
fn body(self: *Response) []const u8
```

```zig
// Returns the response's header map
fn headers(self: *Response) HeaderMap
```

```zig
// Returns the response's status code
fn status(self: *Response) StatusCode
```

```zig
// Returns the response's protocol version
fn version(self: *Response) Version
```

#### `ResponseBuilder`
##### The response builder.

```zig
// The default constructor
default(allocator: *Allocator) ResponseBuilder
```

```zig
// Release the memory allocated by the header map
fn deinit(self: *ResponseBuilder) void
```

```zig
// Set the response's payload.
// This function returns the final response objet or a potential error
// collected during the build steps
fn body(self: *ResponseBuilder, value: []const u8) ResponseError!Response
```

```zig
// Set a response header name and value
fn header(self: *ResponseBuilder, name: []const u8, value: []const u8) *ResponseBuilder
```

```zig
// Set the response's status code
fn status(self: *ResponseBuilder, value: StatusCode) *ResponseBuilder
```

```zig
// Set the response's protocol version
fn version(self: *ResponseBuilder, value: Version) *ResponseBuilder
```

#### `Uri`
##### A valid URI object

[Read more](https://github.com/ducdetronquito/http/blob/master/src/uri/README.md)

### Enumerations

#### `Method`
##### The available request methods.
- Connect
- Custom
- Delete
- Get
- Head
- Options
- Patch
- Post
- Put
- Trace

#### `StatusCode`
##### The available response status codes.

A lot; the list is available on [MDN](https://developer.mozilla.org/fr/docs/Web/HTTP/Status).

#### `Version`
##### The available protocol versions.
- Http09
- Http10
- Http11
- Http2
- Http3


### Errors

##### `HeadersError`

- OutOfMemory
- Invalid


##### `RequestError`

- OutOfMemory
- UriRequired
- [URI errors](https://github.com/ducdetronquito/http/blob/master/src/uri/README.md#error)


##### `ResponseError`

- OutOfMemory


## Requirements

To work with *http* you will need the latest stable version of Zig, which is currently Zig 0.6.0.


## License

*http* is released into the Public Domain. 🎉🍻
The URI parser is a fork of Vexu's [zuri](https://github.com/Vexu/zuri) under the MIT License.
