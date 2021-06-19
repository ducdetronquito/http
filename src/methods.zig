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
    fn is_token(char: u8) callconv(.Inline) bool {
        return char > 0x1f and char < 0x7f;
    }
};

const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;
const expectError = std.testing.expectError;

test "Convert to bytes" {
    var connect = Method { .Connect = undefined };
    try expectEqualStrings(connect.to_bytes(), "CONNECT");

    var lauch_missile = Method { .Custom = "LAUNCH-MISSILE" };
    try expectEqualStrings(lauch_missile.to_bytes(), "LAUNCH-MISSILE");

    var delete = Method { .Delete = undefined };
    try expectEqualStrings(delete.to_bytes(), "DELETE");

    var get = Method { .Get = undefined };
    try expectEqualStrings(get.to_bytes(), "GET");

    var head = Method { .Head = undefined };
    try expectEqualStrings(head.to_bytes(), "HEAD");

    var options = Method { .Options = undefined };
    try expectEqualStrings(options.to_bytes(), "OPTIONS");

    var patch = Method { .Patch = undefined };
    try expectEqualStrings(patch.to_bytes(), "PATCH");

    var post = Method { .Post = undefined };
    try expectEqualStrings(post.to_bytes(), "POST");

    var put = Method { .Put = undefined };
    try expectEqualStrings(put.to_bytes(), "PUT");

    var trace = Method { .Trace = undefined };
    try expectEqualStrings(trace.to_bytes(), "TRACE");
}

test "FromBytes - Success" {
    var method = try Method.from_bytes("CONNECT");
    try expect(method == .Connect);

    method = try Method.from_bytes("DELETE");
    try expect(method == .Delete);

    method = try Method.from_bytes("GET");
    try expect(method == .Get);

    method = try Method.from_bytes("HEAD");
    try expect(method == .Head);

    method = try Method.from_bytes("OPTIONS");
    try expect(method == .Options);

    method = try Method.from_bytes("PATCH");
    try expect(method == .Patch);

    method = try Method.from_bytes("POST");
    try expect(method == .Post);

    method = try Method.from_bytes("PUT");
    try expect(method == .Put);

    method = try Method.from_bytes("TRACE");
    try expect(method == .Trace);

    method = try Method.from_bytes("LAUNCH-MISSILE");
    try expectEqualStrings(method.Custom, "LAUNCH-MISSILE");
}

test "FromBytes - Invalid character" {
    const failure = Method.from_bytes("LAUNCH\r\nMISSILE");
    try expectError(error.Invalid, failure);
}
