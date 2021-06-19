pub const Version = enum {
    Http09,
    Http10,
    Http11,
    Http2,
    Http3,

    pub fn to_bytes(self: Version) []const u8 {
        return switch(self) {
            .Http09 => "HTTP/0.9",
            .Http10 => "HTTP/1.0",
            .Http11 => "HTTP/1.1",
            .Http2 => "HTTP/2",
            .Http3 => "HTTP/3",
        };
    }

    pub fn from_bytes(value: []const u8) ?Version {
        var isInvalid = (
            value.len < 6
            or value.len > 8
            or !std.mem.eql(u8, value[0..5], "HTTP/")
        );
        if (isInvalid) {
            return null;
        }

        if (std.mem.eql(u8, value[5..], "0.9")) {
            return .Http09;
        } else if (std.mem.eql(u8, value[5..], "1.0")) {
            return .Http10;
        } else if (std.mem.eql(u8, value[5..], "1.1")) {
            return .Http11;
        } else if (std.mem.eql(u8, value[5..], "2")) {
            return .Http2;
        } else if (std.mem.eql(u8, value[5..], "3")) {
            return .Http3;
        }

        return null;
    }
};


const expect = std.testing.expect;
const std = @import("std");

test "Convert to bytes" {
    try expect(std.mem.eql(u8, Version.Http09.to_bytes(), "HTTP/0.9"));
    try expect(std.mem.eql(u8, Version.Http10.to_bytes(), "HTTP/1.0"));
    try expect(std.mem.eql(u8, Version.Http11.to_bytes(), "HTTP/1.1"));
    try expect(std.mem.eql(u8, Version.Http2.to_bytes(), "HTTP/2"));
    try expect(std.mem.eql(u8, Version.Http3.to_bytes(), "HTTP/3"));
}

test "From bytes" {
    try expect(Version.from_bytes("HTTP/0.9").? == .Http09);
    try expect(Version.from_bytes("HTTP/1.0").? == .Http10);
    try expect(Version.from_bytes("HTTP/1.1").? == .Http11);
    try expect(Version.from_bytes("HTTP/2").? == .Http2);
    try expect(Version.from_bytes("HTTP/3").? == .Http3);
}

test "From bytes - Invalid" {
    try expect(Version.from_bytes("HTTP") == null);
    try expect(Version.from_bytes("NOOB/") == null);
    try expect(Version.from_bytes("HTTP/4") == null);
    try expect(Version.from_bytes("HTTP/1.111") == null);
}
