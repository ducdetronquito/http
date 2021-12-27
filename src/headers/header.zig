const HeaderName = @import("name.zig").HeaderName;
const HeaderType = @import("name.zig").HeaderType;
const HeaderValue = @import("value.zig").HeaderValue;

pub const Header = struct {
    name: HeaderName,
    value: []const u8,

    pub const Error = HeaderName.Error || HeaderValue.Error;

    pub fn init(name: []const u8, value: []const u8) !Header {
        var _name = try HeaderName.parse(name);
        var _value = try HeaderValue.parse(value);
        return Header{ .name = _name, .value = _value };
    }

    pub fn as_slice(comptime headers: anytype) []Header {
        const typeof = @TypeOf(headers);
        const typeinfo = @typeInfo(typeof);
        switch (typeinfo) {
            .Struct => |obj| {
                comptime {
                    var result: [obj.fields.len]Header = undefined;
                    var i = 0;
                    while (i < obj.fields.len) {
                        _ = HeaderName.parse(headers[i][0]) catch {
                            @compileError("Invalid header name: " ++ headers[i][0]);
                        };

                        _ = HeaderValue.parse(headers[i][1]) catch {
                            @compileError("Invalid header value: " ++ headers[i][1]);
                        };

                        var _type = HeaderType.from_bytes(headers[i][0]);
                        var name = headers[i][0];
                        var value = headers[i][1];
                        result[i] = Header{ .name = .{ .type = _type, .value = name }, .value = value };
                        i += 1;
                    }
                    return &result;
                }
            },
            else => {
                @compileError("The parameter type must be an anonymous list literal.\n" ++ "Ex: Header.as_slice(.{.{\"Gotta-Go\", \"Fast!\"}});");
            },
        }
    }
};

const std = @import("std");
const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;

test "AsSlice" {
    var result = Header.as_slice(.{
        .{ "Content-Length", "9000" },
        .{ "Gotta-Go", "Fast!" },
    });
    try expect(result.len == 2);
    try expect(result[0].name.type == .ContentLength);
    try expectEqualStrings(result[0].name.raw(), "Content-Length");
    try expectEqualStrings(result[0].value, "9000");
    try expect(result[1].name.type == .Custom);
    try expectEqualStrings(result[1].name.raw(), "Gotta-Go");
    try expectEqualStrings(result[1].value, "Fast!");
}
