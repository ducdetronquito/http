pub const MethodType = enum {
    Connect,
    Custom,
    Delete,
    Get,
    Head,
    Options,
    Patch,
    Post,
    Put,
    Trace,
};

pub const Method = union(MethodType) {
    Connect: void,
    Custom: []const u8,
    Delete: void,
    Get: void,
    Head: void,
    Options: void,
    Patch: void,
    Post: void,
    Put: void,
    Trace: void,

    pub fn to_bytes(self: Method) []const u8 {
        return switch(self) {
            .Connect => "CONNECT",
            .Custom => |name| name,
            .Delete => "DELETE",
            .Get => "GET",
            .Head => "HEAD",
            .Options => "OPTIONS",
            .Patch => "PATCH",
            .Post => "POST",
            .Put => "PUT",
            .Trace => "TRACE",
        };
    }
};

const expect = std.testing.expect;
const std = @import("std");

test "Convert to bytes" {
    var connect = Method { .Connect = undefined };
    expect(std.mem.eql(u8, connect.to_bytes(), "CONNECT"));

    var lauch_missile = Method { .Custom = "LAUNCH-MISSILE" };
    expect(std.mem.eql(u8, lauch_missile.to_bytes(), "LAUNCH-MISSILE"));

    var delete = Method { .Delete = undefined };
    expect(std.mem.eql(u8, delete.to_bytes(), "DELETE"));

    var get = Method { .Get = undefined };
    expect(std.mem.eql(u8, get.to_bytes(), "GET"));

    var head = Method { .Head = undefined };
    expect(std.mem.eql(u8, head.to_bytes(), "HEAD"));

    var options = Method { .Options = undefined };
    expect(std.mem.eql(u8, options.to_bytes(), "OPTIONS"));

    var patch = Method { .Patch = undefined };
    expect(std.mem.eql(u8, patch.to_bytes(), "PATCH"));

    var post = Method { .Post = undefined };
    expect(std.mem.eql(u8, post.to_bytes(), "POST"));

    var put = Method { .Put = undefined };
    expect(std.mem.eql(u8, put.to_bytes(), "PUT"));

    var trace = Method { .Trace = undefined };
    expect(std.mem.eql(u8, trace.to_bytes(), "TRACE"));
}
