# Uri

[URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) parser forked from Vexu's [zuri](https://github.com/Vexu/zuri) library.


## Usage

```Zig
const uri = try Uri.parse("https://ziglang.org/documentation/master/#toc-Introduction");
assert(mem.eql(u8, uri.scheme, "https"));
assert(mem.eql(u8, uri.host, "ziglang.org"));
assert(mem.eql(u8, uri.path, "/documentation/master/"));
assert(mem.eql(u8, uri.fragment, "toc-Introduction"));
```


## API Reference

### Errors

##### `Error`

- InvalidCharacter
- EmptyUri
