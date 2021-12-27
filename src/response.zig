const Allocator = std.mem.Allocator;
const Header = @import("./headers/header.zig").Header;
const Headers = @import("./headers/headers.zig").Headers;
const StatusCode = @import("status.zig").StatusCode;
const std = @import("std");
const Version = @import("versions.zig").Version;

const AllocationError = error{
    OutOfMemory,
};

pub const ResponseError = AllocationError || Headers.Error;

pub const ResponseBuilder = struct {
    build_error: ?ResponseError,
    _version: Version,
    _status: StatusCode,
    headers: Headers,

    pub fn default(allocator: Allocator) ResponseBuilder {
        return ResponseBuilder{
            .build_error = null,
            ._version = Version.Http11,
            ._status = .Ok,
            .headers = Headers.init(allocator),
        };
    }

    inline fn build_has_failed(self: *ResponseBuilder) bool {
        return self.build_error != null;
    }

    pub fn body(self: *ResponseBuilder, value: []const u8) ResponseError!Response {
        if (self.build_has_failed()) {
            self.headers.deinit();
            return self.build_error.?;
        }

        return Response{ .version = self._version, .status = self._status, .headers = self.headers, .body = value };
    }

    pub fn header(self: *ResponseBuilder, name: []const u8, value: []const u8) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }

        const _header = Header.init(name, value) catch |err| {
            self.build_error = err;
            return self;
        };
        _ = self.headers.append(_header) catch |err| {
            self.build_error = err;
        };
        return self;
    }

    pub fn status(self: *ResponseBuilder, value: StatusCode) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._status = value;
        return self;
    }

    pub fn version(self: *ResponseBuilder, value: Version) *ResponseBuilder {
        if (self.build_has_failed()) {
            return self;
        }
        self._version = value;
        return self;
    }
};

pub const Response = struct {
    status: StatusCode,
    version: Version,
    headers: Headers,
    body: []const u8,

    pub fn builder(allocator: Allocator) ResponseBuilder {
        return ResponseBuilder.default(allocator);
    }

    pub fn deinit(self: *Response) void {
        self.headers.deinit();
    }
};

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;
const expectError = std.testing.expectError;

test "Build with default values" {
    var response = try Response.builder(std.testing.allocator).body("");
    defer response.deinit();

    try expect(response.version == .Http11);
    try expect(response.status == .Ok);
    try expect(response.headers.len() == 0);
    try expectEqualStrings(response.body, "");
}

test "Build with specific values" {
    var response = try Response.builder(std.testing.allocator)
        .version(.Http11)
        .status(.ImATeapot)
        .header("GOTTA-GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer response.deinit();

    try expect(response.version == .Http11);
    try expect(response.status == .ImATeapot);
    try expectEqualStrings(response.body, "ᕕ( ᐛ )ᕗ");

    var header = response.headers.get("GOTTA-GO").?;
    try expectEqualStrings(header.name.raw(), "GOTTA-GO");
    try expectEqualStrings(header.value, "FAST");
}

test "Build with a custom status code" {
    var custom_status = try StatusCode.from_u16(536);
    var response = try Response.builder(std.testing.allocator)
        .version(.Http11)
        .status(custom_status)
        .header("GOTTA-GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");
    defer response.deinit();

    try expect(response.version == .Http11);
    try expect(response.status == custom_status);
    try expectEqualStrings(response.body, "ᕕ( ᐛ )ᕗ");

    var header = response.headers.get("GOTTA-GO").?;
    try expectEqualStrings(header.name.raw(), "GOTTA-GO");
    try expectEqualStrings(header.value, "FAST");
}

test "Free headers memory on error" {
    const failure = Response.builder(std.testing.allocator)
        .header("GOTTA-GO", "FAST")
        .header("INVALID HEADER", "")
        .body("");

    try expectError(error.InvalidHeaderName, failure);
}

test "Fail to build when out of memory" {
    var buffer: [100]u8 = undefined;
    const allocator = std.heap.FixedBufferAllocator.init(&buffer).allocator();
    const failure = Response.builder(allocator)
        .header("GOTTA-GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");

    try expectError(error.OutOfMemory, failure);
}
