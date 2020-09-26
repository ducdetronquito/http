const Allocator = std.mem.Allocator;
const HeaderMap = @import("headers.zig").HeaderMap;
const StatusCode = @import("status.zig").StatusCode;
const std = @import("std");
const Version = @import("versions.zig").Version;


pub const ResponseError = error {
    OutOfMemory,
};

const Head = struct {
    allocator: *Allocator,
    version: Version,
    status: StatusCode,
    headers: HeaderMap,

    pub fn deinit(self: *Head) void {
        self.headers.deinit();
    }
};

const ResponseBuilder = struct {
    _head: Head,
    build_error: ?ResponseError,

    pub fn default(allocator: *Allocator) ResponseBuilder {
        var default_head = Head {
            .allocator = allocator,
            .version = Version.Http11,
            .status = .Ok,
            .headers = HeaderMap.init(allocator),
        };
        return ResponseBuilder {
            ._head = default_head,
            .build_error = null,
        };
    }

    pub fn deinit(self: *ResponseBuilder) void {
        self._head.deinit();
    }

    inline fn build_has_failed(self: *ResponseBuilder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *ResponseBuilder, value: []const u8) ResponseError!Response {
        if (self.build_has_failed()) {
            return self.build_error.?;
        }

        return Response {
            ._head = self._head,
            ._body = value
        };
    }

    pub fn header(self: *ResponseBuilder, name: []const u8, value: []const u8) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        _ = self._head.headers.put(name, value) catch |err| {
            self.build_error = err;
        };
        return self;
    }

    pub fn status(self: *ResponseBuilder, value: StatusCode) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._head.status = value;
        return self;
    }

    pub fn version(self: *ResponseBuilder, value: Version) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._head.version = value;
        return self;
    }
};


pub const Response = struct {
    _head: Head,
    _body: []const u8,

    pub fn builder(allocator: *Allocator) ResponseBuilder {
        return ResponseBuilder.default(allocator);
    }

    pub fn deinit(self: *Response) void {
        self._head.deinit();
    }

    pub inline fn body(self: *Response) []const u8 {
        return self._body;
    }

    pub inline fn headers(self: *Response) HeaderMap {
        return self._head.headers;
    }

    pub inline fn status(self: *Response) StatusCode {
        return self._head.status;
    }

    pub inline fn version(self: *Response) Version {
        return self._head.version;
    }
};

const expect = std.testing.expect;
const expectError = std.testing.expectError;

test "Response - Build with default values" {
    var response = try Response.builder(std.testing.allocator).body("");
    defer response.deinit();

    expect(response.version() == .Http11);
    expect(response.status() == .Ok);
    expect(response.headers().entries.len == 0);
    expect(std.mem.eql(u8, response.body(), ""));
}

test "Response - Build with specific values" {
    var response = try Response.builder(std.testing.allocator)
        .version(.Http11)
        .status(.ImATeapot)
        .header("GOTTA GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer response.deinit();

    expect(response.version() == .Http11);
    expect(response.status() == .ImATeapot);
    expect(std.mem.eql(u8, response.body(), "ᕕ( ᐛ )ᕗ"));

    var header = response.headers().get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}

test "Response - Build with a custom status code" {
    var custom_status = try StatusCode.from_u16(536);
    var response = try Response.builder(std.testing.allocator)
        .version(.Http11)
        .status(custom_status)
        .header("GOTTA GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer response.deinit();

    expect(response.version() == .Http11);
    expect(response.status() == custom_status);
    expect(std.mem.eql(u8, response.body(), "ᕕ( ᐛ )ᕗ"));

    var header = response.headers().get("GOTTA GO").?;
    expect(std.mem.eql(u8, header.key, "GOTTA GO"));
    expect(std.mem.eql(u8, header.value, "FAST"));
}

test "Response - Fail to build when out of memory" {
    var buffer: [100]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    var response = Response.builder(allocator)
        .header("GOTTA GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");

    expectError(error.OutOfMemory, response);
}
