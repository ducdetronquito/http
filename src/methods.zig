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

    const Error = error {
        Invalid,
    };

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

    pub fn custom(value: []const u8) Error!Method {
        for (value) |char| {
            if (!is_token(char)) {
                return error.Invalid;
            }
        }
        return Method { .Custom = value };
    }

    pub fn from_bytes(value: []const u8) Error!Method {
        switch(value.len) {
            3 => {
                if (std.mem.eql(u8, value, "GET")) {
                    return .Get;
                } else if (std.mem.eql(u8, value, "PUT")) {
                    return .Put;
                }
                else {
                    return try Method.custom(value);
                }
            },
            4 => {
                if (std.mem.eql(u8, value, "HEAD")) {
                    return .Head;
                } else if (std.mem.eql(u8, value, "POST")) {
                    return .Post;
                } else {
                    return try Method.custom(value);
                }
            },
            5 => {
                if (std.mem.eql(u8, value, "PATCH")) {
                    return .Patch;
                } else if (std.mem.eql(u8, value, "TRACE")) {
                    return .Trace;
                } else {
                    return try Method.custom(value);
                }
            },
            6 => {
                if (std.mem.eql(u8, value, "DELETE")) {
                    return .Delete;
                } else {
                    return try Method.custom(value);
                }
            },
            7 => {
                if (std.mem.eql(u8, value, "CONNECT")) {
                    return .Connect;
                } else if (std.mem.eql(u8, value, "OPTIONS")) {
                    return .Options;
                } else {
                    return try Method.custom(value);
                }
            },
            else => {
                return try Method.custom(value);
            }
        }
    }

    // Determines if a character is a token character.
    //
    // Cf: https://tools.ietf.org/html/rfc7230#section-3.2.6
    // > token          = 1*tchar
    // >
    // > tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
    // >                / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
    // >                / DIGIT / ALPHA
    // >                ; any VCHAR, except delimiters
    inline fn is_token(char: u8) bool {
        return char > 0x1f and char < 0x7f;
    }
};


const expect = std.testing.expect;
const expectError = std.testing.expectError;

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
    var method = try Method.from_bytes("CONNECT");
    expect(method== .Connect);

    method = try Method.from_bytes("DELETE");
    expect(method == .Delete);

    method = try Method.from_bytes("GET");
    expect(method == .Get);

    method = try Method.from_bytes("HEAD");
    expect(method == .Head);

    method = try Method.from_bytes("OPTIONS");
    expect(method == .Options);

    method = try Method.from_bytes("PATCH");
    expect(method == .Patch);

    method = try Method.from_bytes("POST");
    expect(method == .Post);

    method = try Method.from_bytes("PUT");
    expect(method == .Put);

    method = try Method.from_bytes("TRACE");
    expect(method == .Trace);

    method = try Method.from_bytes("LAUNCH-MISSILE");
    switch (method) {
        .Custom => |name| expect(std.mem.eql(u8, name, "LAUNCH-MISSILE")),
        else => unreachable,
    }
}

test "FromBytes - Invalid character" {
    const failure = Method.from_bytes("LAUNCH\r\nMISSILE");
    expectError(error.Invalid, failure);
}
