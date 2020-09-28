const Allocator = std.mem.Allocator;
const HeaderMap = @import("headers.zig").HeaderMap;
const Method = @import("methods.zig").Method;
const std = @import("std");
const Uri = @import("uri.zig").Uri;
const UriError = @import("uri.zig").UriError;
const Version = @import("versions.zig").Version;


pub const AllocationError = error {
    OutOfMemory,
};

pub const RequestBuilderError = error {
    UriRequired,
};

pub const RequestError = AllocationError || RequestBuilderError || UriError;

const Head = struct {
    allocator: *Allocator,
    method: Method,
    uri: ?Uri,
    version: Version,
    headers: HeaderMap,

    pub fn deinit(self: *Head) void {
        self.headers.deinit();
    }
};

const RequestBuilder = struct {
    _head: Head,
    build_error: ?RequestError,

    pub fn default(allocator: *Allocator) RequestBuilder {
        var default_head = Head {
            .allocator = allocator,
            .method = Method.Get,
            .uri = null,
            .version = Version.Http11,
            .headers = HeaderMap.init(allocator),
        };
        return RequestBuilder {
            ._head = default_head,
            .build_error = null,
        };
    }

    pub fn deinit(self: *RequestBuilder) void {
        self._head.deinit();
    }

    inline fn build_has_failed(self: *RequestBuilder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *RequestBuilder, value: []const u8) RequestError!Request {
        if (self.build_has_failed()) {
            return self.build_error.?;
        }

        if (self._head.uri == null) {
            return error.UriRequired;
        }

        return Request {
            ._head = self._head,
            ._body = value
        };
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

        _ = self._head.headers.put(name, value) catch |err| {
            self.build_error = err;
        };
        return self;
    }

    pub fn method(self: *RequestBuilder, value: Method) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        self._head.method = value;
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
            self._head.uri = _uri;
        } else |err| {
            self.build_error = err;
        }

        return self;
    }

    pub fn version(self: *RequestBuilder, value: Version) *RequestBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._head.version = value;
        return self;
    }
};


pub const Request = struct {
    _head: Head,
    _body: []const u8,

    pub fn builder(allocator: *Allocator) RequestBuilder {
        return RequestBuilder.default(allocator);
    }

    pub fn deinit(self: *Request) void {
        self._head.deinit();
    }

    pub inline fn body(self: *Request) []const u8 {
        return self._body;
    }

    pub inline fn headers(self: *Request) HeaderMap {
        return self._head.headers;
    }

    pub inline fn method(self: *Request) Method {
        return self._head.method;
    }

    pub inline fn uri(self: *Request) Uri {
        return self._head.uri orelse unreachable;
    }

    pub inline fn version(self: *Request) Version {
        return self._head.version;
    }
};


const expect = std.testing.expect;
const expectError = std.testing.expectError;

test "Build with default values" {
    var request = try Request.builder(std.testing.allocator)
        .uri("https://ziglang.org/")
        .body("");
    defer request.deinit();

    expect(request.method() == Method.Get);
    expect(request.version() == .Http11);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
    expect(request.headers().entries.len == 0);
    expect(std.mem.eql(u8, request.body(), ""));
}

test "Build with specific values" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .uri("https://ziglang.org/")
        .version(.Http11)
        .header("GOTTA GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer request.deinit();

    expect(request.method() == Method.Get);
    expect(request.version() == .Http11);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
    expect(std.mem.eql(u8, request.body(), "ᕕ( ᐛ )ᕗ"));

    var header = request.headers().get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}

test "Build with a custom method" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method { .Custom = "LAUNCH-MISSILE"})
        .uri("https://ziglang.org/")
        .body("");
    defer request.deinit();

    switch(request.method()) {
        .Custom => |value| {
            expect(std.mem.eql(u8, value, "LAUNCH-MISSILE"));
        },
        else => unreachable,
    }
}

test "Fail to build when the URI is missing" {
    var request = Request.builder(std.testing.allocator).body("");
    expectError(error.UriRequired, request);
}

test "Fail to build when the URI is invalid" {
    var request = Request.builder(std.testing.allocator)
        .uri("")
        .body("");
    expectError(error.EmptyUri, request);
}

test "Fail to build when out of memory" {
    var buffer: [100]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    var request = Request.builder(allocator)
        .uri("https://ziglang.org/")
        .header("GOTTA GO", "FAST")
        .body("");

    expectError(error.OutOfMemory, request);
}

test "Build a CONNECT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).connect("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Connect);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build a DELETE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).delete("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Delete);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build a GET request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).get("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Get);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build an HEAD request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).head("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Head);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build an OPTIONS request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).options("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Options);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build an PATCH request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).patch("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Patch);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build a POST request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).post("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Post);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build a PUT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).put("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Put);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}

test "Build a TRACE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).trace("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Trace);
    const expectedUri = try Uri.parse("https://ziglang.org/", false);
    expect(Uri.equals(request.uri(), expectedUri));
}
