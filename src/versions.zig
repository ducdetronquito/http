pub const VersionType = enum {
    Http09,
    Http10,
    Http11,
    Http2,
    Http3,
};


pub const Version = union(VersionType) {
    Http09: void,
    Http10: void,
    Http11: void,
    Http2: void,
    Http3: void,
};
