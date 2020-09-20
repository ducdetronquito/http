const std = @import("std");

// Dumb Header map used to validate the overall API.
// At some point I aim to use a RFC compliant implementation, like the one in the standard lib.
pub const HeaderMap = std.StringHashMap([]const u8);
