const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const HeaderName = @import("name.zig").HeaderName;
const HeaderType = @import("name.zig").HeaderType;
const HeaderValue = @import("value.zig").HeaderValue;


pub const Header = struct {
    name: HeaderName,
    value: []const u8,
};

const AllocationError = error { OutOfMemory };

pub const Headers = struct {
    allocator: *Allocator,
    _items: ArrayList(Header),

    pub const Error = error { Invalid } || AllocationError;

    pub fn init(allocator: *Allocator) Headers {
        return Headers { .allocator = allocator, ._items = ArrayList(Header).init(allocator)};
    }

    pub fn deinit(self: *Headers) void {
        self._items.deinit();
    }

    pub fn add(self: *Headers, name: []const u8, value: []const u8) Error!void {
        var _name = try HeaderName.parse(name);
        var _value = try HeaderValue.parse(value);

        try self._items.append(Header { .name = _name, .value = _value});
    }

    pub inline fn len(self: Headers) usize {
        return self._items.items.len;
    }

    pub inline fn items(self: Headers) []Header {
        return self._items.items;
    }

    pub fn get(self: Headers, name: []const u8) ?Header {
        var _type = HeaderName.type_of(name);

        return switch(_type) {
            .Custom => self.get_custom_header(name),
            else => self.get_standard_header(_type),
        };
    }

    pub fn list(self: Headers, name: []const u8) AllocationError![]Header {
        var _type = HeaderName.type_of(name);
        return switch(_type) {
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
const expectError = std.testing.expectError;

test "Add - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Content-Length", "42");
    expect(headers.len() == 1);
    const header = headers.items()[0];
    expect(header.name.type == .ContentLength);
    expect(std.mem.eql(u8, header.value, "42"));
}

test "Add - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Gotta-Go", "Fast");
    expect(headers.len() == 1);
    const header = headers.items()[0];
    expect(header.name.type == .Custom);
    expect(std.mem.eql(u8, header.name.raw(), "Gotta-Go"));
    expect(std.mem.eql(u8, header.value, "Fast"));
}

test "Add - Invalid header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    var failure = headers.add("Invalid Header", "yeah");
    expectError(error.Invalid, failure);
}

test "Add - Out of memory" {
    var buffer: [1]u8 = undefined;
    const allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;

    var headers = Headers.init(allocator);
    defer headers.deinit();

    var failure = headers.add("Gotta-Go", "Fast");
    expectError(error.OutOfMemory, failure);
}

test "Get - Missing header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    expect(headers.get("Content-Length") == null);
}

test "Get - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Content-Length", "10");

    var result = headers.get("Content-Length").?;
    expect(std.mem.eql(u8, result.value, "10"));
}

test "Get - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Gotta-Go", "Fast");

    var result = headers.get("Gotta-Go").?;
    expect(std.mem.eql(u8, result.value, "Fast"));
}


test "List - Missing header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    var result = try headers.list("Content-Length");
    defer std.testing.allocator.free(result);
    expect(result.len == 0);
}

test "List - Standard header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Content-Length", "10");
    try headers.add("Content-Length", "20");

    var result = try headers.list("Content-Length");
    defer std.testing.allocator.free(result);

    expect(result.len == 2);
    expect(std.mem.eql(u8, result[0].value, "10"));
    expect(std.mem.eql(u8, result[1].value, "20"));
}

test "List - Custom header" {
    var headers = Headers.init(std.testing.allocator);
    defer headers.deinit();

    try headers.add("Gotta-Go", "Fast");
    try headers.add("Gotta-Go", "Very Fast");

    var result = try headers.list("Gotta-Go");
    defer std.testing.allocator.free(result);

    expect(result.len == 2);
    expect(std.mem.eql(u8, result[0].value, "Fast"));
    expect(std.mem.eql(u8, result[1].value, "Very Fast"));
}
