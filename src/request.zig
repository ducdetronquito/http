const Allocator = std.mem.Allocator;
const Headers = @import("./headers/headers.zig").Headers;
const Method = @import("methods.zig").Method;
const std = @import("std");
const Uri = @import("./uri/uri.zig").Uri;
const UriError = @import("./uri/uri.zig").Error;
const Version = @import("versions.zig").Version;

const AllocationError = error{
    OutOfMemory,
};

const RequestBuilderError = error{
    UriRequired,
};

pub const RequestError = AllocationError || RequestBuilderError || UriError || Headers.Error;

pub const RequestBuilder = struct {
    build_error: ?RequestError,
    _method: Method,
    _uri: ?Uri,
    _version: Version,
    headers: Headers,

    pub fn default(allocator: *Allocator) RequestBuilder {
        return RequestBuilder{
            .build_error = null,
            ._method = Method.Get,
            ._uri = null,
            ._version = Version.Http11,
            .headers = Headers.init(allocator),
        };
    }

    inline fn build_has_failed(self: *RequestBuilder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *RequestBuilder, value: []const u8) RequestError!Request {
        if (self.build_has_failed()) {
            self.headers.deinit();
            return self.build_error.?;
        }

        if (self._uri == null) {
            return error.UriRequired;
        }

        return Request{ .method = self._method, .uri = self._uri.?, .version = self._version, .headers = self.headers, .body = value };
    }

    pub fn connect(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Connect).uri(_uri);
    }

    pub fn delete(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Delete).uri(_uri);
    }

    pub fn get(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Get).uri(_uri);
    }

    pub fn head(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Head).uri(_uri);
    }

    pub fn header(self: *RequestBuilder, name: []const u8, value: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        _ = self.headers.append(name, value) catch |err| {
            self.build_error = err;
        };
        return self;
    }

    pub fn method(self: *RequestBuilder, value: Method) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        self._method = value;
        return self;
    }

    pub fn options(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Options).uri(_uri);
    }

    pub fn patch(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Patch).uri(_uri);
    }

    pub fn post(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Post).uri(_uri);
    }

    pub fn put(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Put).uri(_uri);
    }

    pub fn trace(self: *RequestBuilder, _uri: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Trace).uri(_uri);
    }

    pub fn uri(self: *RequestBuilder, value: []const u8) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        if (Uri.parse(value, false)) |_uri| {
            self._uri = _uri;
        } else |err| {
            self.build_error = err;
        }

        return self;
    }

    pub fn version(self: *RequestBuilder, value: Version) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._version = value;
        return self;
    }
};

pub const Request = struct {
    method: Method,
    uri: Uri,
    version: Version,
    headers: Headers,
    body: []const u8,

    pub fn builder(allocator: *Allocator) RequestBuilder {
        return RequestBuilder.default(allocator);
    }

    pub fn deinit(self: *Request) void {
        self.headers.deinit();
    }
};

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;
const expectError = std.testing.expectError;

test "Build with default values" {
    var request = try Request.builder(std.testing.allocator)
        .uri("https://ziglang.org/")
        .body("");
    defer request.deinit();

    try expect(request.method == Method.Get);
    try expect(request.version == .Http11);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
    try expect(request.headers.len() == 0);
    try expectEqualStrings(request.body, "");
}

test "Build with specific values" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .uri("https://ziglang.org/")
        .version(.Http11)
        .header("GOTTA-GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer request.deinit();

    try expect(request.method == Method.Get);
    try expect(request.version == .Http11);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
    try expectEqualStrings(request.body, "ᕕ( ᐛ )ᕗ");

    var header = request.headers.get("GOTTA-GO").?;
    try expectEqualStrings(header.name.raw(), "GOTTA-GO");
    try expectEqualStrings(header.value, "FAST");
}

test "Build with a custom method" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method{ .Custom = "LAUNCH-MISSILE" })
        .uri("https://ziglang.org/")
        .body("");
    defer request.deinit();

    try expectEqualStrings(request.method.Custom, "LAUNCH-MISSILE");
}

test "Fail to build when the URI is missing" {
    const failure = Request.builder(std.testing.allocator).body("");
    try expectError(error.UriRequired, failure);
}

test "Fail to build when the URI is invalid" {
    const failure = Request.builder(std.testing.allocator)
        .uri("")
        .body("");
    try expectError(error.EmptyUri, failure);
}

test "Fail to build when out of memory" {
    var buffer: [100]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    const failure = Request.builder(allocator)
        .uri("https://ziglang.org/")
        .header("GOTTA-GO", "FAST")
        .body("");

    try expectError(error.OutOfMemory, failure);
}

test "Free headers memory on error" {
    const failure = Request.builder(std.testing.allocator)
        .get("https://ziglang.org/")
        .header("GOTTA-GO", "FAST")
        .header("INVALID HEADER", "")
        .body("");

    try expectError(error.InvalidHeaderName, failure);
}

test "Build a CONNECT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).connect("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Connect);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build a DELETE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).delete("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Delete);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build a GET request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).get("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Get);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build an HEAD request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).head("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Head);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build an OPTIONS request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).options("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Options);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build an PATCH request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).patch("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Patch);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build a POST request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).post("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Post);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build a PUT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).put("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Put);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}

test "Build a TRACE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).trace("https://ziglang.org/").body("");
    defer request.deinit();

    try expect(request.method == .Trace);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    try expect(Uri.equals(request.uri, expectedUri));
}
