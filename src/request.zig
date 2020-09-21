const Allocator = std.mem.Allocator;
const HeaderMap = @import("headers.zig").HeaderMap;
const Method = @import("methods.zig").Method;
const std = @import("std");
const Uri = @import("uri.zig").Uri;


pub const RequestError = error {
    Invalid,
};


const Head = struct {
    allocator: *Allocator,
    method: Method,
    uri: Uri,
    version: []const u8,
    headers: HeaderMap,

    pub fn deinit(self: *Head) void {
        self.headers.deinit();
    }
};


const Builder = struct {
    _head: Head,
    build_error: ?RequestError,

    pub fn default(allocator: *Allocator) Builder {
        var default_head = Head {
            .allocator = allocator,
            .method = Method.Get,
            .uri = Uri { .value = ""},
            .version = "HTTP/1.1",
            .headers = HeaderMap.init(allocator),
        };
        return Builder {
            ._head = default_head,
            .build_error = null,
        };
    }

    pub fn deinit(self: *Builder) void {
        self._head.deinit();
    }

    inline fn build_has_failed(self: *Builder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *Builder, value: []const u8) RequestError!Request {
        if (self.build_has_failed()) {
            return self.build_error.?;
        }

        return Request {
            .head = self._head,
            .body = value
        };
    }

    pub fn connect(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Connect).uri(_uri);
    }

    pub fn delete(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Delete).uri(_uri);
    }

    pub fn get(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Get).uri(_uri);
    }

    pub fn head(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Head).uri(_uri);
    }

    pub fn header(self: *Builder, name: []const u8, value: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        _ = self._head.headers.put(name, value) catch {
            self.build_error = error.Invalid;
        };
        return self;
    }

    pub fn method(self: *Builder, value: Method) *Builder {
        if (self.build_has_failed()) {
            return self;
        }
        self._head.method = value;
        return self;
    }

    pub fn options(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Options).uri(_uri);
    }

    pub fn patch(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Patch).uri(_uri);
    }

    pub fn post(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Post).uri(_uri);
    }

    pub fn put(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Put).uri(_uri);
    }

    pub fn trace(self: *Builder, _uri: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        return self.method(.Trace).uri(_uri);
    }

    pub fn uri(self: *Builder, value: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }
        self._head.uri = Uri.parse(value);
        return self;
    }
};


pub const Request = struct {
    head: Head,
    body: []const u8,

    pub fn builder(allocator: *Allocator) Builder {
        return Builder.default(allocator);
    }

    pub fn deinit(self: *Request) void {
        self.head.deinit();
    }
};


const expect = std.testing.expect;

test "Build a default request" {
    var request = try Request.builder(std.testing.allocator).body("");
    defer request.deinit();

    expect(request.head.method == Method.Get);
    expect(std.mem.eql(u8, request.head.version, "HTTP/1.1"));
    expect(std.mem.eql(u8, request.head.uri.value, ""));
    expect(std.mem.eql(u8, request.body, ""));
    expect(request.head.headers.entries.len == 0);
}

test "Build a request" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .uri("https://ziglang.org/")
        .header("GOTTA GO", "FAST")
        .body("");
    defer request.deinit();

    expect(request.head.method == Method.Get);
    expect(std.mem.eql(u8, request.head.version, "HTTP/1.1"));
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
    expect(std.mem.eql(u8, request.body, ""));

    var header = request.head.headers.get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}

test "Build a request with method custom method" {
    var request = try Request.builder(std.testing.allocator)
        .method(Method { .Custom = "LAUNCH-MISSILE"})
        .body("");
    defer request.deinit();

    switch(request.head.method) {
        .Custom => |value| {
            expect(std.mem.eql(u8, value, "LAUNCH-MISSILE"));
        },
        else => unreachable,
    }
}


test "Build a Connect request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).connect("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Connect);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build a Delete request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).delete("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Delete);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build a Get request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).get("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Get);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build an Head request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).head("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Head);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build an Options request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).options("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Options);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build an Patch request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).patch("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Patch);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build a Post request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).post("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Post);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build a Put request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).put("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Put);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}

test "Build a Trace request with the shortcut method" {
    var request = try Request.builder(std.testing.allocator).trace("https://ziglang.org/").body("");
    defer request.deinit();

    expect(request.head.method == .Trace);
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
}
