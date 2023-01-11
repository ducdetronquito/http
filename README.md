# HTTP

HTTP core types for Zig inspired by Rust [http](https://github.com/hyperium/http).

[![Build Status](https://api.travis-ci.org/ducdetronquito/http.svg?branch=master)](https://travis-ci.org/ducdetronquito/http) [![License](https://img.shields.io/badge/License-BSD%200--Clause-ff69b4.svg)](https://github.com/ducdetronquito/http#license) [![Requirements](https://img.shields.io/badge/zig-0.10.0-orange)](https://ziglang.org/)

⚠️ I'm currently renovating an old house which does not allow me to work on [requestz](https://github.com/ducdetronquito/requestz/), [h11](https://github.com/ducdetronquito/h11/) and [http](https://github.com/ducdetronquito/http) anymore. Feel free to fork or borrow some ideas if there are any good ones :)


## Installation

*http* is available on [astrolabe.pm](https://astrolabe.pm/) via [gyro](https://github.com/mattnite/gyro)

```
gyro add ducdetronquito/http
```

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
fn append(self: *Headers, name: []const u8, value: []const u8) !void
```

```zig
// Retrieve the first matching header
fn get(self: Headers, name: []const u8) ?Header
```

```zig
// Retrieve a list of matching headers
fn list(self: Headers, name: []const u8) ![]Header
```

```zig
// Retrieve the number of headers
fn len(self: Headers) usize
```

```zig
// Retrieve all headers
fn items(self: Headers) []Header
```

Header issues are tracked here: [#2](https://github.com/ducdetronquito/http/issues/2)


#### `Request`
##### An HTTP request object produced by the request builder.

```zig
const Request = struct {
    method: Method,
    uri: Uri,
    version: Version,
    headers: Headers,
    body: []const u8,
};
```

```zig
// The default constructor to start building a request
fn builder(allocator: *Allocator) RequestBuilder
```

```zig
// Release the memory allocated by the headers
fn deinit(self: *Request) void
```

#### `RequestBuilder`
##### The request builder.

```zig
// The default constructor
default(allocator: *Allocator) RequestBuilder
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
const Response = struct {
    status: StatusCode,
    version: Version,
    headers: Headers,
    body: []const u8,
};
```

```zig
// The default constructor to start building a response
fn builder(allocator: *Allocator) ResponseBuilder
```

#### `ResponseBuilder`
##### The response builder.

```zig
// The default constructor
default(allocator: *Allocator) ResponseBuilder
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

## License

*http* is released under the [BSD Zero clause license](https://choosealicense.com/licenses/0bsd/). 🎉🍻

The URI parser is a fork of Vexu's [zuri](https://github.com/Vexu/zuri) under the MIT License.
