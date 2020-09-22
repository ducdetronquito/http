const Allocator = std.mem.Allocator;
const HeaderMap = @import("headers.zig").HeaderMap;
const Method = @import("methods.zig").Method;
const std = @import("std");
const Uri = @import("uri.zig").Uri;
const Version = @import("versions.zig").Version;


pub const RequestError = error {
    Invalid,
};


const Head = struct {
    allocator: *Allocator,
    method: Method,
    uri: Uri,
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
            .uri = Uri { .value = ""},
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

        _ = self._head.headers.put(name, value) catch {
            self.build_error = error.Invalid;
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
        self._head.uri = Uri.parse(value);
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
        return self._head.uri;
    }

    pub inline fn version(self: *Request) Version {
        return self._head.version;
    }
};


const expect = std.testing.expect;

test "Request - Build with default values" {
    var request = try Request.builder(std.testing.allocator).body("");
    defer request.deinit();

    expect(request.method() == Method.Get);
    expect(request.version() == .Http11);
    expect(std.mem.eql(u8, request.uri().value, ""));
    expect(request.headers().entries.len == 0);
    expect(std.mem.eql(u8, request.body(), ""));
}

test "Request - Build with specific values" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .uri("https://ziglang.org/")
        .version(.Http11)
        .header("GOTTA GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer request.deinit();

    expect(request.method() == Method.Get);
    expect(request.version() == .Http11);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
    expect(std.mem.eql(u8, request.body(), "ᕕ( ᐛ )ᕗ"));

    var header = request.headers().get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}

test "Request - Build with a custom method" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method { .Custom = "LAUNCH-MISSILE"})
        .body("");
    defer request.deinit();

    switch(request.method()) {
        .Custom => |value| {
            expect(std.mem.eql(u8, value, "LAUNCH-MISSILE"));
        },
        else => unreachable,
    }
}

test "REquest - Build a CONNECT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).connect("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Connect);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build a DELETE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).delete("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Delete);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build a GET request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).get("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Get);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build an HEAD request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).head("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Head);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build an OPTIONS request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).options("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Options);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build an PATCH request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).patch("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Patch);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build a POST request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).post("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Post);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build a PUT request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).put("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Put);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}

test "Request - Build a TRACE request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).trace("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.method() == .Trace);
    expect(std.mem.eql(u8, request.uri().value, "https://ziglang.org/"));
}
