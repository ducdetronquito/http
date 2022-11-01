const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const Header = @import("header.zig").Header;
const HeaderName = @import("name.zig").HeaderName;
const HeaderType = @import("name.zig").HeaderType;
const HeaderValue = @import("value.zig").HeaderValue;
const std = @import("std");

const AllocationError = error{OutOfMemory};

pub const Headers = struct {
    allocator: Allocator,
    _items: ArrayList(Header),

    pub const Error = error{ InvalidHeaderName, InvalidHeaderValue } || AllocationError;

    pub fn init(allocator: Allocator) Headers {
        return Headers{ .allocator = allocator, ._items = ArrayList(Header).init(allocator) };
    }

    pub fn deinit(self: *Headers) void {
        self._items.deinit();
    }

    pub fn append(self: *Headers, name: []const u8, value: []const u8) Error!void {
        var _name = HeaderName.parse(name) catch return error.InvalidHeaderName;
        var _value = HeaderValue.parse(value) catch return error.InvalidHeaderValue;

        try self._items.append(Header{ .name = _name, .value = _value });
    }

    pub inline fn len(self: Headers) usize {
        return self._items.items.len;
    }

    pub inline fn items(self: Headers) []Header {
        return self._items.items;
    }

    pub fn get(self: Headers, name: []const u8) ?Header {
        var _type = HeaderName.type_of(name);

        return switch (_type) {
            .Custom => self.get_custom_header(name),
            else => self.get_standard_header(_type),
        };
    }

    pub fn list(self: Headers, name: []const u8) AllocationError![]Header {
        var _type = HeaderName.type_of(name);
        return switch (_type) {
            .Custom => self.get_custom_header_list(name),
            else => self.get_standard_header_list(_type),
        };
    }

    inline fn get_custom_header_list(self: Headers, name: []const u8) AllocationError![]Header {
        var result = ArrayList(Header).init(self.allocator);
        for (self.items()) |header| {
            if (header.name.type == .Custom and std.mem.eql(u8, header.name.raw(), name)) {
                try result.append(header);
            }
        }
        return result.toOwnedSlice();
    }

    inline fn get_standard_header_list(self: Headers, name: HeaderType) AllocationError![]Header {
        var result = ArrayList(Header).init(self.allocator);
        for (self.items()) |header| {
            if (header.name.type == name) {
                try result.append(header);
            }
        }
        return result.toOwnedSlice();
    }

    inline fn get_custom_header(self: Headers, name: []const u8) ?Header {
        for (self.items()) |header| {
            if (header.name.type == .Custom and std.mem.eql(u8, header.name.raw(), name)) {
                return header;
            }
        }
        return null;
    }

    inline fn get_standard_header(self: Headers, name: HeaderType) ?Header {
        for (self.items()) |header| {
            if (header.name.type == name) {
                return header;
            }
        }
        return null;
    }
};

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;
const expectError = std.testing.expectError;

test "Append - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Content-Length", "42");

    try expect(headers.len() == 1);
    const header = headers.items()[0];
    try expect(header.name.type == .ContentLength);
    try expectEqualStrings(header.value, "42");
}

test "Append - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Gotta-Go", "Fast");

    try expect(headers.len() == 1);
    const header = headers.items()[0];
    try expect(header.name.type == .Custom);
    try expectEqualStrings(header.name.raw(), "Gotta-Go");
    try expectEqualStrings(header.value, "Fast");
}

test "Append - Invalid header name" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    var failure = headers.append("Invalid Header", "yeah");

    try expectError(error.InvalidHeaderName, failure);
}

test "Append - Invalid header value" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    var failure = headers.append("name", "I\nvalid");

    try expectError(error.InvalidHeaderValue, failure);
}

test "Append - Out of memory" {
    var buffer: [1]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    var headers = Headers.init(fba.allocator());
    defer headers.deinit();

    var failure = headers.append("Gotta-Go", "Fast");
    try expectError(error.OutOfMemory, failure);
}

test "Get - Missing header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try expect(headers.get("Content-Length") == null);
}

test "Get - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Content-Length", "10");

    var result = headers.get("Content-Length").?;
    try expectEqualStrings(result.value, "10");
}

test "Get - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Gotta-Go", "Fast");

    var result = headers.get("Gotta-Go").?;
    try expectEqualStrings(result.value, "Fast");
}

test "List - Missing header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    var result = try headers.list("Content-Length");
    defer std.testing.allocator.free(result);
    try expect(result.len == 0);
}

test "List - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Content-Length", "10");
    try headers.append("Content-Length", "20");

    var result = try headers.list("Content-Length");
    defer std.testing.allocator.free(result);

    try expect(result.len == 2);
    try expectEqualStrings(result[0].value, "10");
    try expectEqualStrings(result[1].value, "20");
}

test "List - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.append("Gotta-Go", "Fast");
    try headers.append("Gotta-Go", "Very Fast");

    var result = try headers.list("Gotta-Go");
    defer std.testing.allocator.free(result);

    try expect(result.len == 2);
    try expectEqualStrings(result[0].value, "Fast");
    try expectEqualStrings(result[1].value, "Very Fast");
}
