// These are the libraries used in the examples,
// you may find the respostories from build.zig.zon
const std = @import("std");
const app = @import("application.zig");

pub fn main() !void {
    std.debug.print("<!--Skri-a Kaark-->\n", .{});
    app.run();
}
