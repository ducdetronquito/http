pub const HeaderValue = struct {
    const Error = error {
        Invalid,
    };

    pub fn parse(value: []const u8) Error![]const u8 {
        if (value.len == 0) {
            return error.Invalid;
        }

        for (value) |char| {
            if (!HEADER_VALUE_MAP[char]) {
                return error.Invalid;
            }
        }
        return value;
    }
};

// ASCII codes accepted for an header's value
// Cf: Borrowed from Seamonstar's httparse library
// https://github.com/seanmonstar/httparse/blob/01e68542605d8a24a707536561c27a336d4090dc/src/lib.rs#L120
const HEADER_VALUE_MAP = [_]bool {
    false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false,
//   \0                                                             \t    \n                   \r
    false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
//   commands
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
//   \s    !     "     #     $     %     &     '     (     )     *     +     ,     -     .     /
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
//   0     1     2     3     4     5     6     7     8     9     :     ;     <     =     >     ?
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
//   @     A     B     C     D     E     F     G     H     I     J     K     L     M     N     O
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
//   P     Q     R     S     T     U     V     W     X     Y     Z     [     \     ]     ^     _
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
//   `     a     b     c     d     e     f     g     h     i     j     k     l     m     n     o
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false,
//   p     q     r     s     t     u     v     w     x     y     z     {     |     }     ~     del
//   ====== Extended ASCII (aka. obs-text) ======
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true,
};


const std = @import("std");
const expectEqualStrings = std.testing.expectEqualStrings;
const expectError = std.testing.expectError;

test "Parse - Success" {
    var value = try HeaderValue.parse("A tasty cookie");

    try expectEqualStrings(value, "A tasty cookie");
}

test "Parse - Invalid character returns an error" {
    const fail = HeaderValue.parse("A invalid\rcookie");

    try expectError(error.Invalid, fail);
}

test "Parse - Empty value is invalid" {
    const fail = HeaderValue.parse("");

    try expectError(error.Invalid, fail);
}
