// These are the libraries used in the examples,
// you may find the respostories from build.zig.zon
const glfw = @import("zglfw");
const gl = @import("gl");
const std = @import("std");
const app = @import("application.zig");

pub fn main() !void {
    std.debug.print("<!--Skri-a Kaark-->", .{});
    try app.init_default();

    app.render = render;
    try app.render(69);

    std.debug.print("\nwindow name {s}\n", .{app.info.title});
}

fn render(input: f64) anyerror!void {
    std.debug.print("\n{d} 420\n", .{input});
}
