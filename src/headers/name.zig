pub const HeaderType = enum {
    ContentLength,
    Host,
    Custom,

    inline fn lowercased_equals(lowered:[]const u8, value: []const u8) bool {
        for (value) |char, i| {
            if (HEADER_NAME_MAP[char] != lowered[i]) {
                return false;
            }
        }
        return true;
    }

    pub fn from_bytes(value: []const u8) HeaderType {
        return switch(value.len) {
            4 => {
                if (lowercased_equals("host", value)) {
                    return .Host;
                } else {
                    return .Custom;
                }
            },
            14 => {
                if (lowercased_equals("content-length", value)) {
                    return .ContentLength;
                }
                else {
                    return .Custom;
                }
            },
            else => {
                return .Custom;
            }
        };
    }

    pub fn as_http1(self: HeaderType, value: []const u8) []const u8 {
        return switch(self) {
            .ContentLength => "Content-Length",
            .Host => "Host",
            else => value,
        };
    }

    pub fn as_http2(self: HeaderType, value: []const u8) []const u8 {
        return switch(self) {
            .ContentLength => "content-length",
            .Host => "host",
            else => value,
        };
    }
};


pub const HeaderName = struct {
    type: HeaderType,
    value: []const u8,

    const Error = error {
        Invalid,
    };

    pub fn parse(name: []const u8) Error!HeaderName {
        if (name.len == 0) {
            return error.Invalid;
        }

        for(name) |char| {
            if (HEADER_NAME_MAP[char] == 0) {
                return error.Invalid;
            }
        }
        return HeaderName { .type = HeaderType.from_bytes(name), .value = name };
    }

    pub inline fn raw(self: HeaderName) []const u8 {
        return self.value;
    }

    pub inline fn as_http1(self: HeaderName) []const u8 {
        return self.type.as_http1(self.value);
    }

    pub inline fn as_http2(self: HeaderName) []const u8 {
        return self.type.as_http2(self.value);
    }

    pub fn type_of(name: []const u8) HeaderType {
        return HeaderType.from_bytes(name);
    }
 };

// ASCII codes accepted for an header's name
// Cf: Borrowed from Seamonstar's httparse library
// https://github.com/seanmonstar/httparse/blob/01e68542605d8a24a707536561c27a336d4090dc/src/lib.rs#L96
const HEADER_NAME_MAP = [_]u8 {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
//  \0                         \t \n       \r
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
//   commands
    0, '!', 0, '#', '$', '%', '&', '\'', 0, 0, '*', '+', 0, '-', '.', 0,
//  \s      "                            (  )            ,            /
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 0, 0, 0, 0, 0, 0,
//                                                    :  ;  <  =  >  ?
    0, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
//  @   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 0, 0, 0, '^', '_',
//   P    Q    R    S    T    U    V    W    X    Y    Z   [  \  ]
    '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
//
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 0, '|', 0, '~', 0,
//                                                         {       }      del
//   ====== Extended ASCII (aka. obs-text) ======
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

const std = @import("std");
const expect = std.testing.expect;
const expectError = std.testing.expectError;

test "Parse - Standard header names have a lower-cased representation" {
    var name = try HeaderName.parse("Content-Length");
    expect(std.mem.eql(u8, name.raw(), "Content-Length"));
    expect(name.type == .ContentLength);
}

test "Parse - Standard header names tagging is case insensitive" {
    var name = try HeaderName.parse("CoNtEnT-LeNgTh");
    expect(std.mem.eql(u8, name.raw(), "CoNtEnT-LeNgTh"));
    expect(name.type == .ContentLength);
}

test "Parse - Custom header names have no lower-cased representation" {
    var name = try HeaderName.parse("Gotta-Go-Fast");
    expect(std.mem.eql(u8, name.raw(), "Gotta-Go-Fast"));
    expect(name.type == .Custom);
}

test "Parse - Invalid character returns an error" {
    const fail = HeaderName.parse("Cont(ent-Length");

    expectError(error.Invalid, fail);
}

test "Parse - Empty name is invalid" {
    const fail = HeaderName.parse("");

    expectError(error.Invalid, fail);
}

test "TypeOf - Standard header name" {
    expect(HeaderName.type_of("Content-Length") == .ContentLength);
    expect(HeaderName.type_of("Host") == .Host);
}

test "TypeOf - Standard headers matching is case insensitive" {
    expect(HeaderName.type_of("CoNTeNt-LeNgTh") == .ContentLength);
}

test "TypeOf - Custom header" {
    expect(HeaderName.type_of("Gotta-Go-Fast") == .Custom);
}

test "AsHttp1 - Standard headers are titled" {
    var name = try HeaderName.parse("Content-Length");

    expect(std.mem.eql(u8, name.as_http1(), "Content-Length"));
}

test "AsHttp1 - Custom headers keeps their case" {
    var name = try HeaderName.parse("Gotta-Go-Fast");

    expect(std.mem.eql(u8, name.as_http1(), "Gotta-Go-Fast"));
}

test "AsHttp2 - Standard headers are lowercased" {
    var name = try HeaderName.parse("Content-Length");

    expect(std.mem.eql(u8, name.as_http2(), "content-length"));
}

test "AsHttp2 - Custom headers keeps their case" {
    var name = try HeaderName.parse("Gotta-Go-Fast");

    expect(std.mem.eql(u8, name.as_http2(), "Gotta-Go-Fast"));
}
