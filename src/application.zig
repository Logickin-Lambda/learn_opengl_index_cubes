const glfw = @import("zglfw");
const gl = @import("gl");
const std = @import("std");
const builtin = @import("builtin");

pub const APPINFOTAG = enum {
    struct_type,
    c_uint_type,
};

const FLAGS = struct {
    all: c_uint = 0,
    fullscreen: c_uint = 1,
    vsync: c_uint = 1,
    cursor: c_uint = 1,
    stereo: c_uint = 1,
    debug: c_uint = 1,
    robust: c_uint = 1,
};

const APPINFO = struct {
    title: [128:0]u8 = undefined,
    windowWidth: c_int = 800,
    windowHeight: c_int = 600,
    majorVersion: c_int = 4,
    minorversion: c_int = 3,
    samples: c_int = 0,
    flags: FLAGS,
};

var info = APPINFO{ .flags = FLAGS{} };
var window: *glfw.Window = undefined;
var allocator: std.mem.allocator = undefined;

// public virtual functions
// these two emulate the constructor and destructor
pub var construct: *const fn () anyerror!void = virtual_void;
pub var destruct: *const fn () anyerror!void = virtual_void;

// others are the original methods
pub var init: *const fn () void = init_default();
pub var start_up: *const fn () anyerror!void = virtual_void;
pub var render: *const fn (f64) anyerror!void = virtual_f64_void;
pub var shutdown: *const fn () anyerror!void = virtual_void;
pub var on_resize: *const fn (c_int, c_int) anyerror!void = virtual_2c_int_void;
pub var on_key: *const fn (c_int, c_int) anyerror!void = virtual_2c_int_void;
pub var on_mouse_button: *const fn (c_int, c_int) anyerror!void = virtual_2c_int_void;
pub var on_mouse_move: *const fn (c_int, c_int) anyerror!void = virtual_2c_int_void;
pub var on_mouse_wheel: *const fn (c_int) anyerror!void = virtual_c_int_void;
pub var get_mouse_position: *const fn (*c_int, *c_int) anyerror!void = virtual_c_int_void;

/// The original function also has window: *glfw.Window as parameter,
/// but since zig don't have the concept of object, please apply application.windows
/// explicitly as a substitution
pub var glfw_onResize: *const fn (c_int, c_int) anyerror!void = virtual_2c_int_void;

// placeholder functions
pub fn virtual_void() anyerror!void {
    return error.OperationNotSupportedError;
}

pub fn virtual_f64_void(_: f64) anyerror!void {
    return error.OperationNotSupportedError;
}

pub fn virtual_c_int_void(_: c_int, _: c_int) void {
    return error.OperationNotSupportedError;
}

pub fn virtual_2c_int_void(_: c_int, _: c_int) void {
    return error.OperationNotSupportedError;
}

pub fn virtual_2c_int_ptr_void(_: *c_int, _: *c_int) void {
    return error.OperationNotSupportedError;
}

// concrete functions:
// pub fn set_v_sync(enable: bool) void {}

pub fn set_window_title(title: [:0]const u8) void {
    glfw.setWindowTitle(window, title);
}

fn init_default() void {
    const title = "OpenGL SuperBible Example" ++ " " ** 103;
    info.title = title;
    info.windowWidth = 800;
    info.windowHeight = 600;

    // this is the zig version of
    // #ifdef __APPLE__
    if (comptime builtin.target.os.tag == .macos) {
        info.majorVersion = 3;
        info.minorversion = 2;
    }

    if (comptime builtin.mode == .Debug) {
        info.flags.debug = 1;
    }
}

fn string_copy(title: *[]u8, input: []u8) void {
    for (input, 0..) |char, i| {
        title[i] = char;
    }
}
