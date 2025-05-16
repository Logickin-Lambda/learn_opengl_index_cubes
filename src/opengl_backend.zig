const glfw_raw = @import("zglfw");
const gl_raw = @import("gl");
const std = @import("std");

pub const APPINFOTAG = enum {
    struct_type,
    c_uint_type,
};

pub fn Application() type {
    return struct {
        const Self = @This();
        pub const APPINFO = struct {
            title: [128]u8,
            windowWidth: c_int,
            windowHeight: c_int,
            majorVersion: c_int,
            minorversion: c_int,
            samples: c_int,
            flags: union(APPINFOTAG) {
                struct_type: type,
                c_uint_type: c_uint,
            } = .{
                .struct_type = struct {
                    fullscreen: c_uint = 1,
                    vsync: c_uint = 1,
                    cursor: c_uint = 1,
                    stereo: c_uint = 1,
                    debug: c_uint = 1,
                    robust: c_uint = 1,
                },
                .c_uint_type = 0,
            },
        };

        glfw: *type,
        gl: *type,
        window: *glfw_raw.Window,
        allocator: std.mem.Allocator,

        construct: fn () void,
        destruct: fn () void,
        init: fn () void,
        startup: fn () void,
        render: fn (f64) void,
        shutdown: fn () void,
        onResize: fn (c_int, c_int) void,
        onKey: fn (c_int, c_int) void,
        onMousebutton: fn (c_int, c_int) void,
        onMouseMove: fn (c_int, c_int) void,
        onMouseWheel: fn (c_int, c_int) void,
        getMousePosition: fn (*c_int, *c_int) void,

        // here are all those non virtual methods from the sb7.h
        pub fn setWindowTitle(self: *Self, title: []u8) void {
            glfw_raw.setWindowTitle(self.window, title);
        }
    };
}
