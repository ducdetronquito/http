const std = @import("std");

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

    pub fn from_bytes(value: []const u8) Method {
        switch(value.len) {
            3 => {
                if (std.mem.eql(u8, value, "GET")) {
                    return .Get;
                } else if (std.mem.eql(u8, value, "PUT")) {
                    return .Put;
                }
                else {
                    return Method { .Custom = value };
                }
            },
            4 => {
                if (std.mem.eql(u8, value, "HEAD")) {
                    return .Head;
                } else if (std.mem.eql(u8, value, "POST")) {
                    return .Post;
                } else {
                    return Method { .Custom = value };
                }
            },
            5 => {
                if (std.mem.eql(u8, value, "PATCH")) {
                    return .Patch;
                } else if (std.mem.eql(u8, value, "TRACE")) {
                    return .Trace;
                } else {
                    return Method { .Custom = value };
                }
            },
            6 => {
                if (std.mem.eql(u8, value, "DELETE")) {
                    return .Delete;
                } else {
                    return Method { .Custom = value };
                }
            },
            7 => {
                if (std.mem.eql(u8, value, "CONNECT")) {
                    return .Connect;
                } else if (std.mem.eql(u8, value, "OPTIONS")) {
                    return .Options;
                } else {
                    return Method { .Custom = value };
                }
            },
            else => {
                return Method { .Custom = value };
            }
        }
    }
};

const expect = std.testing.expect;

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

test "FromBytes - Success" {
    expect(Method.from_bytes("CONNECT") == .Connect);
    expect(Method.from_bytes("DELETE") == .Delete);
    expect(Method.from_bytes("GET") == .Get);
    expect(Method.from_bytes("HEAD") == .Head);
    expect(Method.from_bytes("OPTIONS") == .Options);
    expect(Method.from_bytes("PATCH") == .Patch);
    expect(Method.from_bytes("POST") == .Post);
    expect(Method.from_bytes("PUT") == .Put);
    expect(Method.from_bytes("TRACE") == .Trace);

    switch (Method.from_bytes("LAUNCH-MISSILE")) {
        .Custom => |name| expect(std.mem.eql(u8, name, "LAUNCH-MISSILE")),
        else => unreachable,
    }
}
