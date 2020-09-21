# HTTP

HTTP core types for Zig inspired by Rust [http](https://github.com/hyperium/http).

[![Build Status](https://api.travis-ci.org/ducdetronquito/http.svg?branch=master)](https://travis-ci.org/ducdetronquito/http) [![License](https://img.shields.io/badge/license-public%20domain-ff69b4.svg)](https://github.com/ducdetronquito/http#license) [![Requirements](https://img.shields.io/badge/zig-0.6.0-orange)](https://ziglang.org/)


# Usage

```zig
const Method = @import("http").Method;
const Request = @import("http").Request;

var request = try Request.builder(std.testing.allocator)
    .method(.Get)
    .uri("https://ziglang.org/")
    .header("GOTTA GO", "FAST")
    .body("");
defer request.deinit();
```

## Requirements

To work with *http* you will need the latest stable version of Zig, which is currently Zig 0.6.0.


## License

*http* is released into the Public Domain. 🎉🍻
