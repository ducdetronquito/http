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

    pub const Error = Header.Error || AllocationError;

    pub fn init(allocator: Allocator) Headers {
        return Headers{ .allocator = allocator, ._items = ArrayList(Header).init(allocator) };
    }

    pub fn deinit(self: *Headers) void {
        self._items.deinit();
    }

    pub fn toOwnedSlice(self: *Headers) []Header {
        var result = self._items.toOwnedSlice();
        self.deinit();
        return result;
    }

    pub fn append(self: *Headers, header: Header) AllocationError!void {
        try self._items.append(header);
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

test "Append - Success" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    const header = try Header.init("Content-Length", "42");
    try headers.append(header);

    try expect(headers.len() == 1);
}

test "Append - Out of memory" {
    var buffer: [1]u8 = undefined;
    const allocator = std.heap.FixedBufferAllocator.init(&buffer).allocator();

    var headers = Headers.init(allocator);
    defer headers.deinit();

    const header = try Header.init("Gotta-Go", "Fast");
    var failure = headers.append(header);

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

    const header = try Header.init("Content-Length", "10");
    try headers.append(header);

    var result = headers.get("Content-Length").?;
    try expectEqualStrings(result.value, "10");
}

test "Get - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    const header = try Header.init("Gotta-Go", "Fast");
    try headers.append(header);

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

    const header = try Header.init("Content-Length", "10");
    try headers.append(header);

    const second_header = try Header.init("Content-Length", "20");
    try headers.append(second_header);

    var result = try headers.list("Content-Length");
    defer std.testing.allocator.free(result);

    try expect(result.len == 2);
    try expectEqualStrings(result[0].value, "10");
    try expectEqualStrings(result[1].value, "20");
}

test "List - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    const header = try Header.init("Gotta-Go", "Fast");
    try headers.append(header);
    const second_header = try Header.init("Gotta-Go", "Very Fast");
    try headers.append(second_header);

    var result = try headers.list("Gotta-Go");
    defer std.testing.allocator.free(result);

    try expect(result.len == 2);
    try expectEqualStrings(result[0].value, "Fast");
    try expectEqualStrings(result[1].value, "Very Fast");
}
