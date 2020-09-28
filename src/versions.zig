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
};


const expect = std.testing.expect;
const std = @import("std");

test "Convert to bytes" {
    expect(std.mem.eql(u8, Version.Http09.to_bytes(), "HTTP/0.9"));
    expect(std.mem.eql(u8, Version.Http10.to_bytes(), "HTTP/1.0"));
    expect(std.mem.eql(u8, Version.Http11.to_bytes(), "HTTP/1.1"));
    expect(std.mem.eql(u8, Version.Http2.to_bytes(), "HTTP/2"));
    expect(std.mem.eql(u8, Version.Http3.to_bytes(), "HTTP/3"));
}
