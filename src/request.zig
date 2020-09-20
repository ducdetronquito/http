const Allocator = std.mem.Allocator;
const HeaderMap = @import("headers.zig").HeaderMap;
const std = @import("std");
const Uri = @import("uri.zig").Uri;


pub const RequestError = error {
    Invalid,
};


const Head = struct {
    allocator: *Allocator,
    method: []const u8,
    uri: Uri,
    version: []const u8,
    headers: HeaderMap,

    pub fn deinit(self: *Head) void {
        self.headers.deinit();
    }
};


const Builder = struct {
    head: Head,
    build_error: ?RequestError,

    pub fn default(allocator: *Allocator) Builder {
        var default_head = Head {
            .allocator = allocator,
            .method = "GET",
            .uri = Uri { .value = ""},
            .version = "HTTP/1.1",
            .headers = HeaderMap.init(allocator),
        };
        return Builder {
            .head = default_head,
            .build_error = null,
        };
    }

    pub fn uri(self: *Builder, value: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }
        self.head.uri = Uri.parse(value);
        return self;
    }

    pub fn header(self: *Builder, name: []const u8, value: []const u8) *Builder {
        if (self.build_has_failed()) {
            return self;
        }

        _ = self.head.headers.put(name, value) catch {
            self.build_error = error.Invalid;
        };
        return self;
    }

    pub fn deinit(self: *Builder) void {
        self.head.deinit();
    }

    inline fn build_has_failed(self: *Builder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *Builder, value: []const u8) RequestError!Request {
        if (self.build_has_failed()) {
            return self.build_error.?;
        }

        return Request {
            .head = self.head,
            .body = value
        };
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

test "Builder" {
    var request = Request.builder(std.testing.allocator);
    defer request.deinit();
}

test "Builder with uri" {
    var request = Request.builder(std.testing.allocator);
    defer request.deinit();
}

test "Builder with headers" {
    var request = Request.builder(std.testing.allocator).header("GOTTA GO", "FAST");
    defer request.deinit();
}

test "Builder produce a request" {
    var request = try Request.builder(std.testing.allocator).uri("https://ziglang.org/").header("GOTTA GO", "FAST").body("");
    defer request.deinit();

    expect(std.mem.eql(u8, request.head.method, "GET"));
    expect(std.mem.eql(u8, request.head.version, "HTTP/1.1"));
    expect(std.mem.eql(u8, request.head.uri.value, "https://ziglang.org/"));
    expect(std.mem.eql(u8, request.body, ""));

    var header = request.head.headers.get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}
