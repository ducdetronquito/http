
// Dumb URI type used to validate the overall API.
// At some point I aim to use a RFC compliant implementation, like Vexu/zuri.
pub const Uri = struct {
    value: []const u8,

    pub fn parse(uri: []const u8) Uri {
        return Uri { .value = uri };
    }
};
