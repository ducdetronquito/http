pub const HeaderType = enum {
    Accept,
    AcceptCharset,
    AcceptEncoding,
    AcceptLanguage,
    AcceptRanges,
    AccessControlAllowCredentials,
    AccessControlAllowHeaders,
    AccessControlAllowMethods,
    AccessControlAllowOrigin,
    AccessControlExposeHeaders,
    AccessControlMaxAge,
    AccessControlRequestHeaders,
    AccessControlRequestMethod,
    Age,
    Allow,
    AltSvc,
    Authorization,
    CacheControl,
    Connection,
    ContentDisposition,
    ContentEncoding,
    ContentLanguage,
    ContentLength,
    ContentLocation,
    ContentRange,
    ContentSecurityPolicy,
    ContentSecurityPolicyReportOnly,
    ContentType,
    Cookie,
    Custom,
    Dnt,
    Date,
    Etag,
    Expect,
    Expires,
    Forwarded,
    From,
    Host,
    IfMatch,
    IfModifiedSince,
    IfNoneMatch,
    IfRange,
    IfUnmodifiedSince,
    LastModified,
    Link,
    Location,
    MaxForwards,
    Origin,
    Pragma,
    ProxyAuthenticate,
    ProxyAuthorization,
    PublicKeyPins,
    Range,
    Referer,
    ReferrerPolicy,
    Refresh,
    RetryAfter,
    SecWebSocketAccept,
    SecWebSocketExtensions,
    SecWebSocketKey,
    SecWebSocketProtocol,
    SecWebSocketVersion,
    Server,
    SetCookie,
    StrictTransportSecurity,
    Te,
    Trailer,
    TransferEncoding,
    UserAgent,
    Upgrade,
    UpgradeInsecureRequests,
    Vary,
    Via,
    Warning,
    WwwAuthenticate,
    XContentTypeOptions,
    XDnsPrefetchControl,
    XFrameOptions,
    XXssProtection,

    inline fn lowercased_equals(lowered:[]const u8, value: []const u8) bool {
        if (lowered.len != value.len) {
            return false;
        }

        for (value) |char, i| {
            if (HEADER_NAME_MAP[char] != lowered[i]) {
                return false;
            }
        }
        return true;
    }

    pub fn from_bytes(value: []const u8) HeaderType {
        switch(value.len) {
            2 => {
                if (lowercased_equals("te", value)) {
                    return .Te;
                }
            },
            3 => {
                if (lowercased_equals("age", value)) {
                    return .Age;
                } else if (lowercased_equals("dnt", value)) {
                    return .Dnt;
                } else if (lowercased_equals("via", value)) {
                    return .Via;
                }
            },
            4 => {
                if (lowercased_equals("host", value)) {
                    return .Host;
                } else if (lowercased_equals("date", value)) {
                    return .Date;
                } else if (lowercased_equals("etag", value)) {
                    return .Etag;
                } else if (lowercased_equals("from", value)) {
                    return .From;
                } else if (lowercased_equals("link", value)) {
                    return .Link;
                } else if (lowercased_equals("vary", value)) {
                    return .Vary;
                }
            },
            5 => {
                if (lowercased_equals("allow", value)) {
                    return .Allow;
                } else if (lowercased_equals("range", value)) {
                    return .Range;
                }
            },
            6 => {
                if (lowercased_equals("accept", value)) {
                    return .Accept;
                } else if (lowercased_equals("cookie", value)) {
                    return .Cookie;
                } else if (lowercased_equals("expect", value)) {
                    return .Expect;
                } else if (lowercased_equals("origin", value)) {
                    return .Origin;
                } else if (lowercased_equals("pragma", value)) {
                    return .Pragma;
                } else if (lowercased_equals("server", value)) {
                    return .Server;
                }
            },
            7 => {
                if (lowercased_equals("alt-svc", value)) {
                    return .AltSvc;
                } else if (lowercased_equals("expires", value)) {
                    return .Expires;
                } else if (lowercased_equals("referer", value)) {
                    return .Referer;
                } else if (lowercased_equals("refresh", value)) {
                    return .Refresh;
                } else if (lowercased_equals("trailer", value)) {
                    return .Trailer;
                } else if (lowercased_equals("upgrade", value)) {
                    return .Upgrade;
                } else if (lowercased_equals("warning", value)) {
                    return .Warning;
                }
            },
            8 => {
                if (lowercased_equals("if-match", value)) {
                    return .IfMatch;
                } else if (lowercased_equals("if-range", value)) {
                    return .IfRange;
                } else if (lowercased_equals("location", value)) {
                    return .Location;
                }
            },
            9 => {
                if (lowercased_equals("forwarded", value)) {
                    return .Forwarded;
                }
            },
            10 => {
                if (lowercased_equals("connection", value)) {
                    return .Connection;
                } else if (lowercased_equals("set-cookie", value)) {
                    return .SetCookie;
                } else if (lowercased_equals("user-agent", value)) {
                    return .UserAgent;
                }
            },
            11 => {
                if (lowercased_equals("retry-after", value)) {
                    return .RetryAfter;
                }
            },
            12 => {
                if (lowercased_equals("content-type", value)) {
                    return .ContentType;
                } else if (lowercased_equals("max-forwards", value)) {
                    return .MaxForwards;
                }
            },
            13 => {
                if (lowercased_equals("accept-ranges", value)) {
                    return .AcceptRanges;
                } else if (lowercased_equals("authorization", value)) {
                    return .Authorization;
                } else if (lowercased_equals("cache-control", value)) {
                    return .CacheControl;
                } else if (lowercased_equals("content-range", value)) {
                    return .ContentRange;
                } else if (lowercased_equals("if-none-match", value)) {
                    return .IfNoneMatch;
                } else if (lowercased_equals("last-modified", value)) {
                    return .LastModified;
                }
            },
            14 => {
                if (lowercased_equals("content-length", value)) {
                    return .ContentLength;
                } else if (lowercased_equals("accept-charset", value)) {
                    return .AcceptCharset;
                }
            },
            15 => {
                if (lowercased_equals("accept-encoding", value)) {
                    return .AcceptEncoding;
                } else if (lowercased_equals("accept-language", value)) {
                    return .AcceptLanguage;
                } else if (lowercased_equals("public-key-pins", value)) {
                    return .PublicKeyPins;
                } else if (lowercased_equals("referrer-policy", value)) {
                    return .ReferrerPolicy;
                } else if (lowercased_equals("x-frame-options", value)) {
                    return .XFrameOptions;
                }
            },
            16 => {
                if (lowercased_equals("content-encoding", value)) {
                    return .ContentEncoding;
                } else if (lowercased_equals("content-language", value)) {
                    return .ContentLanguage;
                } else if (lowercased_equals("content-location", value)) {
                    return .ContentLocation;
                } else if (lowercased_equals("www-authenticate", value)) {
                    return .WwwAuthenticate;
                } else if (lowercased_equals("x-xss-protection", value)) {
                    return .XXssProtection;
                }
            },
            17 => {
                if (lowercased_equals("if-modified-since", value)) {
                    return .IfModifiedSince;
                } else if (lowercased_equals("sec-websocket-key", value)) {
                    return .SecWebSocketKey;
                } else if (lowercased_equals("transfer-encoding", value)) {
                    return .TransferEncoding;
                }
            },
            18 => {
                if (lowercased_equals("proxy-authenticate", value)) {
                    return .ProxyAuthenticate;
                }
            },
            19 => {
                if (lowercased_equals("content-disposition", value)) {
                    return .ContentDisposition;
                } else if (lowercased_equals("if-unmodified-since", value)) {
                    return .IfUnmodifiedSince;
                } else if (lowercased_equals("proxy-authorization", value)) {
                    return .ProxyAuthorization;
                }
            },
            20 => {
                if (lowercased_equals("sec-websocket-accept", value)) {
                    return .SecWebSocketAccept;
                }
            },
            21 => {
                if (lowercased_equals("sec-websocket-version", value)) {
                    return .SecWebSocketVersion;
                }
            },
            22 => {
                if (lowercased_equals("access-control-max-age", value)) {
                    return .AccessControlMaxAge;
                } else if (lowercased_equals("sec-websocket-protocol", value)) {
                    return .SecWebSocketProtocol;
                } else if (lowercased_equals("x-content-type-options", value)) {
                    return .XContentTypeOptions;
                } else if (lowercased_equals("x-dns-prefetch-control", value)) {
                    return .XDnsPrefetchControl;
                }
            },
            23 => {
                if (lowercased_equals("content-security-policy", value)) {
                    return .ContentSecurityPolicy;
                }
            },
            24 => {
                if (lowercased_equals("sec-websocket-extensions", value)) {
                    return .SecWebSocketExtensions;
                }
            },
            25 => {
                if (lowercased_equals("strict-transport-security", value)) {
                    return .StrictTransportSecurity;
                } else if (lowercased_equals("upgrade-insecure-requests", value)) {
                    return .UpgradeInsecureRequests;
                }
            },
            27 => {
                if (lowercased_equals("access-control-allow-origin", value)) {
                    return .AccessControlAllowOrigin;
                }
            },
            28 => {
                if (lowercased_equals("access-control-allow-headers", value)) {
                    return .AccessControlAllowHeaders;
                } else if (lowercased_equals("access-control-allow-methods", value)) {
                    return .AccessControlAllowMethods;
                }
            },
            29 => {
                if (lowercased_equals("access-control-expose-headers", value)) {
                    return .AccessControlExposeHeaders;
                } else if (lowercased_equals("access-control-request-method", value)) {
                    return .AccessControlRequestMethod;
                }
            },
            30 => {
                if (lowercased_equals("access-control-request-headers", value)) {
                    return .AccessControlRequestHeaders;
                }
            },
            32 => {
                if (lowercased_equals("access-control-allow-credentials", value)) {
                    return .AccessControlAllowCredentials;
                }
            },
            35 => {
                if (lowercased_equals("content-security-policy-report-only", value)) {
                    return .ContentSecurityPolicyReportOnly;
                }
            },
            else => {
                return .Custom;
            }
        }
        return .Custom;
    }

    pub fn as_http1(self: HeaderType, value: []const u8) []const u8 {
        return switch(self) {
            .Accept => "Accept",
            .AcceptCharset => "Accept-Charset",
            .AcceptEncoding => "Accept-Encoding",
            .AcceptLanguage => "Accept-Language",
            .AcceptRanges => "Accept-Ranges",
            .AccessControlAllowCredentials => "Access-Control-Allow-Credentials",
            .AccessControlAllowHeaders => "Access-Control-Allow-Headers",
            .AccessControlAllowMethods => "Access-Control-Allow-Methods",
            .AccessControlAllowOrigin => "Access-Control-Allow-Origin",
            .AccessControlExposeHeaders => "Access-Control-Expose-Headers",
            .AccessControlMaxAge => "Access-Control-Max-Age",
            .AccessControlRequestHeaders => "Access-Control-Request-Headers",
            .AccessControlRequestMethod => "Access-Control-Request-Method",
            .Age => "Age",
            .Allow => "Allow",
            .AltSvc => "Alt-Svc",
            .Authorization => "Authorization",
            .CacheControl => "Cache-Control",
            .Connection => "Connection",
            .ContentDisposition => "Content-Disposition",
            .ContentEncoding => "Content-Encoding",
            .ContentLanguage => "Content-Language",
            .ContentLength => "Content-Length",
            .ContentLocation => "Content-Location",
            .ContentRange => "Content-Range",
            .ContentSecurityPolicy => "Content-Security-Policy",
            .ContentSecurityPolicyReportOnly => "Content-Security-Policy-Report-Only",
            .ContentType => "Content-Type",
            .Cookie => "Cookie",
            .Custom => value,
            .Date => "Date",
            .Dnt => "Dnt",
            .Etag => "Etag",
            .Expect => "Expect",
            .Expires => "Expires",
            .Forwarded => "Forwarded",
            .From => "From",
            .Host => "Host",
            .IfMatch => "If-Match",
            .IfModifiedSince => "If-Modified-Since",
            .IfNoneMatch => "If-None-Match",
            .IfRange => "If-Range",
            .IfUnmodifiedSince => "If-Unmodified-Since",
            .LastModified => "Last-Modified",
            .Link => "Link",
            .Location => "Location",
            .MaxForwards => "Max-Forwards",
            .Origin => "Origin",
            .Pragma => "Pragma",
            .ProxyAuthenticate => "Proxy-Authenticate",
            .ProxyAuthorization => "Proxy-Authorization",
            .PublicKeyPins => "Public-Key-Pins",
            .Range => "Range",
            .Referer => "Referer",
            .ReferrerPolicy => "Referrer-Policy",
            .Refresh => "Refresh",
            .RetryAfter => "Retry-After",
            .SecWebSocketAccept => "Sec-WebSocket-Accept",
            .SecWebSocketExtensions => "Sec-WebSocket-Extensions",
            .SecWebSocketKey => "Sec-WebSocket-Key",
            .SecWebSocketProtocol => "Sec-WebSocket-Protocol",
            .SecWebSocketVersion => "Sec-WebSocket-Version",
            .Server => "Server",
            .SetCookie => "Set-Cookie",
            .StrictTransportSecurity => "Strict-Transport-Security",
            .Te => "Te",
            .Trailer => "Trailer",
            .TransferEncoding => "Transfer-Encoding",
            .UserAgent => "User-Agent",
            .Upgrade => "Upgrade",
            .UpgradeInsecureRequests => "Upgrade-Insecure-Requests",
            .Vary => "Vary",
            .Via => "Via",
            .Warning => "Warning",
            .WwwAuthenticate => "WWW-Authenticate",
            .XContentTypeOptions => "X-Content-Type-Options",
            .XDnsPrefetchControl => "X-DNS-Prefetch-Control",
            .XFrameOptions => "X-Frame-Options",
            .XXssProtection => "X-XSS-Protection",
        };
    }

    pub fn as_http2(self: HeaderType, value: []const u8) []const u8 {
        return switch(self) {
            .Accept => "accept",
            .AcceptCharset => "accept-charset",
            .AcceptEncoding => "accept-encoding",
            .AcceptLanguage => "accept-language",
            .AcceptRanges => "accept-ranges",
            .AccessControlAllowCredentials => "access-control-allow-credentials",
            .AccessControlAllowHeaders => "access-control-allow-headers",
            .AccessControlAllowMethods => "access-control-allow-methods",
            .AccessControlAllowOrigin => "access-control-allow-origin",
            .AccessControlExposeHeaders => "access-control-expose-headers",
            .AccessControlMaxAge => "access-control-max-age",
            .AccessControlRequestHeaders => "access-control-request-headers",
            .AccessControlRequestMethod => "access-control-request-method",
            .Age => "age",
            .Allow => "allow",
            .AltSvc => "alt-svc",
            .Authorization => "authorization",
            .CacheControl => "cache-control",
            .Connection => "connection",
            .ContentDisposition => "content-disposition",
            .ContentEncoding => "content-encoding",
            .ContentLanguage => "content-language",
            .ContentLength => "content-length",
            .ContentLocation => "content-location",
            .ContentRange => "content-range",
            .ContentSecurityPolicy => "content-security-policy",
            .ContentSecurityPolicyReportOnly => "content-security-policy-report-only",
            .ContentType => "content-type",
            .Cookie => "cookie",
            .Custom => value,
            .Date => "date",
            .Dnt => "dnt",
            .Etag => "etag",
            .Expect => "expect",
            .Expires => "expires",
            .Forwarded => "forwarded",
            .From => "from",
            .Host => "host",
            .IfMatch => "if-match",
            .IfModifiedSince => "if-modified-since",
            .IfNoneMatch => "if-none-match",
            .IfRange => "if-range",
            .IfUnmodifiedSince => "if-unmodified-since",
            .LastModified => "last-modified",
            .Link => "link",
            .Location => "location",
            .MaxForwards => "max-forwards",
            .Origin => "origin",
            .Pragma => "pragma",
            .ProxyAuthenticate => "proxy-authenticate",
            .ProxyAuthorization => "proxy-authorization",
            .PublicKeyPins => "public-key-pins",
            .Range => "range",
            .Referer => "referer",
            .ReferrerPolicy => "referrer-policy",
            .Refresh => "refresh",
            .RetryAfter => "retry-after",
            .SecWebSocketAccept => "sec-websocket-accept",
            .SecWebSocketExtensions => "sec-websocket-extensions",
            .SecWebSocketKey => "sec-websocket-key",
            .SecWebSocketProtocol => "sec-websocket-protocol",
            .SecWebSocketVersion => "sec-websocket-version",
            .Server => "server",
            .SetCookie => "set-cookie",
            .StrictTransportSecurity => "strict-transport-security",
            .Te => "te",
            .Trailer => "trailer",
            .TransferEncoding => "transfer-encoding",
            .UserAgent => "user-agent",
            .Upgrade => "upgrade",
            .UpgradeInsecureRequests => "upgrade-insecure-requests",
            .Vary => "vary",
            .Via => "via",
            .Warning => "warning",
            .WwwAuthenticate => "www-authenticate",
            .XContentTypeOptions => "x-content-type-options",
            .XDnsPrefetchControl => "x-dns-prefetch-control",
            .XFrameOptions => "x-frame-options",
            .XXssProtection => "x-xss-protection",
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

test "Parse" {
    const Case = struct {
        value: []const u8,
        type: HeaderType,
        http1: []const u8,
        http2: []const u8,
    };

    var cases = [_]Case {
        .{.value = "Accept", .type = .Accept, .http1 = "Accept", .http2 = "accept" },
        .{.value = "Accept-Charset", .type = .AcceptCharset, .http1 = "Accept-Charset", .http2 = "accept-charset" },
        .{.value = "Accept-Encoding", .type = .AcceptEncoding, .http1 = "Accept-Encoding", .http2 = "accept-encoding" },
        .{.value = "Accept-Language", .type = .AcceptLanguage, .http1 = "Accept-Language", .http2 = "accept-language" },
        .{.value = "Accept-Ranges", .type = .AcceptRanges, .http1 = "Accept-Ranges", .http2 = "accept-ranges" },
        .{.value = "Access-Control-Allow-Credentials", .type = .AccessControlAllowCredentials, .http1 = "Access-Control-Allow-Credentials", .http2 = "access-control-allow-credentials" },
        .{.value = "Access-Control-Allow-Headers", .type = .AccessControlAllowHeaders, .http1 = "Access-Control-Allow-Headers", .http2 = "access-control-allow-headers" },
        .{.value = "Access-Control-Allow-Methods", .type = .AccessControlAllowMethods, .http1 = "Access-Control-Allow-Methods", .http2 = "access-control-allow-methods" },
        .{.value = "Access-Control-Allow-Origin", .type = .AccessControlAllowOrigin, .http1 = "Access-Control-Allow-Origin", .http2 = "access-control-allow-origin" },
        .{.value = "Access-Control-Expose-Headers", .type = .AccessControlExposeHeaders, .http1 = "Access-Control-Expose-Headers", .http2 = "access-control-expose-headers" },
        .{.value = "Access-Control-Max-Age", .type = .AccessControlMaxAge, .http1 = "Access-Control-Max-Age", .http2 = "access-control-max-age" },
        .{.value = "Access-Control-Request-Headers", .type = .AccessControlRequestHeaders, .http1 = "Access-Control-Request-Headers", .http2 = "access-control-request-headers" },
        .{.value = "Access-Control-Request-Method", .type = .AccessControlRequestMethod, .http1 = "Access-Control-Request-Method", .http2 = "access-control-request-method" },
        .{.value = "Age", .type = .Age, .http1 = "Age", .http2 = "age" },
        .{.value = "Allow", .type = .Allow, .http1 = "Allow", .http2 = "allow" },
        .{.value = "Alt-Svc", .type = .AltSvc, .http1 = "Alt-Svc", .http2 = "alt-svc" },
        .{.value = "Authorization", .type = .Authorization, .http1 = "Authorization", .http2 = "authorization" },
        .{.value = "Cache-Control", .type = .CacheControl, .http1 = "Cache-Control", .http2 = "cache-control" },
        .{.value = "Connection", .type = .Connection, .http1 = "Connection", .http2 = "connection" },
        .{.value = "Content-Length", .type = .ContentLength, .http1 = "Content-Length", .http2 = "content-length" },
        .{.value = "Content-Location", .type = .ContentLocation, .http1 = "Content-Location", .http2 = "content-location" },
        .{.value = "Content-Range", .type = .ContentRange, .http1 = "Content-Range", .http2 = "content-range" },
        .{.value = "Content-Security-Policy", .type = .ContentSecurityPolicy, .http1 = "Content-Security-Policy", .http2 = "content-security-policy" },
        .{.value = "Content-Security-Policy-Report-Only", .type = .ContentSecurityPolicyReportOnly, .http1 = "Content-Security-Policy-Report-Only", .http2 = "content-security-policy-report-only" },
        .{.value = "Content-Type", .type = .ContentType, .http1 = "Content-Type", .http2 = "content-type" },
        .{.value = "Cookie", .type = .Cookie, .http1 = "Cookie", .http2 = "cookie" },
        .{.value = "I-Am-A-Custom-Header", .type = .Custom, .http1 = "I-Am-A-Custom-Header", .http2 = "I-Am-A-Custom-Header" },
        .{.value = "Dnt", .type = .Dnt, .http1 = "Dnt", .http2 = "dnt" },
        .{.value = "Date", .type = .Date, .http1 = "Date", .http2 = "date" },
        .{.value = "Etag", .type = .Etag, .http1 = "Etag", .http2 = "etag" },
        .{.value = "Expect", .type = .Expect, .http1 = "Expect", .http2 = "expect" },
        .{.value = "Expires", .type = .Expires, .http1 = "Expires", .http2 = "expires" },
        .{.value = "Forwarded", .type = .Forwarded, .http1 = "Forwarded", .http2 = "forwarded" },
        .{.value = "From", .type = .From, .http1 = "From", .http2 = "from" },
        .{.value = "Host", .type = .Host, .http1 = "Host", .http2 = "host" },
        .{.value = "If-Match", .type = .IfMatch, .http1 = "If-Match", .http2 = "if-match" },
        .{.value = "If-Modified-Since", .type = .IfModifiedSince, .http1 = "If-Modified-Since", .http2 = "if-modified-since" },
        .{.value = "If-None-Match", .type = .IfNoneMatch, .http1 = "If-None-Match", .http2 = "if-none-match" },
        .{.value = "If-Range", .type = .IfRange, .http1 = "If-Range", .http2 = "if-range" },
        .{.value = "If-Unmodified-Since", .type = .IfUnmodifiedSince, .http1 = "If-Unmodified-Since", .http2 = "if-unmodified-since" },
        .{.value = "Last-Modified", .type = .LastModified, .http1 = "Last-Modified", .http2 = "last-modified" },
        .{.value = "Link", .type = .Link, .http1 = "Link", .http2 = "link" },
        .{.value = "Location", .type = .Location, .http1 = "Location", .http2 = "location" },
        .{.value = "Max-Forwards", .type = .MaxForwards, .http1 = "Max-Forwards", .http2 = "max-forwards" },
        .{.value = "Origin", .type = .Origin, .http1 = "Origin", .http2 = "origin" },
        .{.value = "Pragma", .type = .Pragma, .http1 = "Pragma", .http2 = "pragma" },
        .{.value = "Proxy-Authenticate", .type = .ProxyAuthenticate, .http1 = "Proxy-Authenticate", .http2 = "proxy-authenticate" },
        .{.value = "Proxy-Authorization", .type = .ProxyAuthorization, .http1 = "Proxy-Authorization", .http2 = "proxy-authorization" },
        .{.value = "Public-Key-Pins", .type = .PublicKeyPins, .http1 = "Public-Key-Pins", .http2 = "public-key-pins" },
        .{.value = "Range", .type = .Range, .http1 = "Range", .http2 = "range" },
        .{.value = "Referer", .type = .Referer, .http1 = "Referer", .http2 = "referer" },
        .{.value = "Referrer-Policy", .type = .ReferrerPolicy, .http1 = "Referrer-Policy", .http2 = "referrer-policy" },
        .{.value = "Refresh", .type = .Refresh, .http1 = "Refresh", .http2 = "refresh" },
        .{.value = "Retry-After", .type = .RetryAfter, .http1 = "Retry-After", .http2 = "retry-after" },
        .{.value = "Sec-WebSocket-Accept", .type = .SecWebSocketAccept, .http1 = "Sec-WebSocket-Accept", .http2 = "sec-websocket-accept" },
        .{.value = "Sec-WebSocket-Extensions", .type = .SecWebSocketExtensions, .http1 = "Sec-WebSocket-Extensions", .http2 = "sec-websocket-extensions" },
        .{.value = "Sec-WebSocket-Key", .type = .SecWebSocketKey, .http1 = "Sec-WebSocket-Key", .http2 = "sec-websocket-key" },
        .{.value = "Sec-WebSocket-Protocol", .type = .SecWebSocketProtocol, .http1 = "Sec-WebSocket-Protocol", .http2 = "sec-websocket-protocol" },
        .{.value = "Sec-WebSocket-Version", .type = .SecWebSocketVersion, .http1 = "Sec-WebSocket-Version", .http2 = "sec-websocket-version" },
        .{.value = "Server", .type = .Server, .http1 = "Server", .http2 = "server" },
        .{.value = "Set-Cookie", .type = .SetCookie, .http1 = "Set-Cookie", .http2 = "set-cookie" },
        .{.value = "Strict-Transport-Security", .type = .StrictTransportSecurity, .http1 = "Strict-Transport-Security", .http2 = "strict-transport-security" },
        .{.value = "Te", .type = .Te, .http1 = "Te", .http2 = "te" },
        .{.value = "Trailer", .type = .Trailer, .http1 = "Trailer", .http2 = "trailer" },
        .{.value = "Transfer-Encoding", .type = .TransferEncoding, .http1 = "Transfer-Encoding", .http2 = "transfer-encoding" },
        .{.value = "User-Agent", .type = .UserAgent, .http1 = "User-Agent", .http2 = "user-agent" },
        .{.value = "Upgrade", .type = .Upgrade, .http1 = "Upgrade", .http2 = "upgrade" },
        .{.value = "Upgrade-Insecure-Requests", .type = .UpgradeInsecureRequests, .http1 = "Upgrade-Insecure-Requests", .http2 = "upgrade-insecure-requests" },
        .{.value = "Vary", .type = .Vary, .http1 = "Vary", .http2 = "vary" },
        .{.value = "Via", .type = .Via, .http1 = "Via", .http2 = "via" },
        .{.value = "Warning", .type = .Warning, .http1 = "Warning", .http2 = "warning" },
        .{.value = "WWW-Authenticate", .type = .WwwAuthenticate, .http1 = "WWW-Authenticate", .http2 = "www-authenticate" },
        .{.value = "X-Content-Type-Options", .type = .XContentTypeOptions, .http1 = "X-Content-Type-Options", .http2 = "x-content-type-options" },
        .{.value = "X-DNS-Prefetch-Control", .type = .XDnsPrefetchControl, .http1 = "X-DNS-Prefetch-Control", .http2 = "x-dns-prefetch-control" },
        .{.value = "X-Frame-Options", .type = .XFrameOptions, .http1 = "X-Frame-Options", .http2 = "x-frame-options" },
        .{.value = "X-XSS-Protection", .type = .XXssProtection, .http1 = "X-XSS-Protection", .http2 = "x-xss-protection" },
    };

    for (cases) |case| {
        var name = try HeaderName.parse(case.value);
        expect(name.type == case.type);
        expect(std.mem.eql(u8, name.as_http1(), case.http1));
        expect(std.mem.eql(u8, name.as_http2(), case.http2));
    }
}
