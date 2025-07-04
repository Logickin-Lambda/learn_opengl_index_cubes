// These are the libraries used in the examples,
// you may find the respostories from build.zig.zon
const std = @import("std");
const zm = @import("zm");

const app = @import("sb7.zig");
const shader = @import("shaders_cubes.zig");

var program: app.gl.uint = undefined;
var vao: app.gl.uint = undefined;

// Additional variables for the cube example, compared to the triangle example
var mv_location: app.gl.int = undefined;
var proj_location: app.gl.int = undefined;
var position_buffer: app.gl.uint = undefined;
var index_buffer: app.gl.uint = undefined;

const MANY_CUBES = false;

pub fn main() !void {
    // Many people seem to hate the dynamic loading part of the program.
    // I also hate it too, but I don't seem to find a good solution (yet)
    // that is aligned with both zig good practice and the book
    // which is unfortunately abstracted all tbe inner details.

    // "override" your program using function pointer,
    // and the run function will process them all
    app.init = init;
    app.start_up = startup;
    app.render = render;
    app.shutdown = shutdown;
    app.run();
}

fn init() anyerror!void {
    app.init_default();
    app.info.flags.cursor = 1;
    app.info.flags.debug = 1;
    std.mem.copyForwards(u8, &app.info.title, "OpenGL SuperBible - Indexed Cube");
}

fn startup() callconv(.c) void {
    // loading, compiling and verifying shaders
    // variables for verifications
    var success: c_int = undefined;
    var infoLog: [512:0]u8 = undefined;

    program = app.gl.CreateProgram();

    // vertex shader
    const vs: app.gl.uint = app.gl.CreateShader(app.gl.VERTEX_SHADER);
    app.gl.ShaderSource(
        vs,
        1,
        &.{shader.vertexShaderImpl},
        &.{shader.vertexShaderImpl.len},
    );
    app.gl.CompileShader(vs);
    app.verifyShader(vs, &success, &infoLog) catch {
        return;
    };

    // fragment shader
    const fs: app.gl.uint = app.gl.CreateShader(app.gl.FRAGMENT_SHADER);
    app.gl.ShaderSource(
        fs,
        1,
        &.{shader.fragmentShaderImpl},
        &.{@as(c_int, @intCast(shader.fragmentShaderImpl.len))},
    );
    app.gl.CompileShader(fs);
    app.verifyShader(fs, &success, &infoLog) catch {
        return;
    };

    app.gl.AttachShader(program, vs);
    app.gl.AttachShader(program, fs);

    app.gl.LinkProgram(program);
    app.verifyProgram(program, &success, &infoLog) catch {
        return;
    };

    // NEW: get the uniform matrix defined from the shader program
    // which are the mv_matrix and proj_matrix
    mv_location = app.gl.GetUniformLocation(program, "mv_matrix");
    proj_location = app.gl.GetUniformLocation(program, "proj_matrix");

    // as usual, creating the vertex arrays
    app.gl.GenVertexArrays(1, (&vao)[0..1]);
    app.gl.BindVertexArray(vao);

    // NEW: adding two arrays, vertex_positions[] and vertex_indices[]
    // to state where 8 vertices are and how they are connected to form a cube

    // this tells the position to the relative
    // vertex index. The first trine represents the
    // location of vertex 0, following by the second
    // trine for vertex 1, and so on.
    const vertex_positions = [_]app.gl.float{
        -0.25, -0.25, -0.25,
        -0.25, 0.25,  -0.25,
        0.25,  -0.25, -0.25,
        0.25,  0.25,  -0.25,
        0.25,  -0.25, 0.25,
        0.25,  0.25,  0.25,
        -0.25, -0.25, 0.25,
        -0.25, 0.25,  0.25,
    };

    // this tells the orientation of the vertices, grouped in three.
    // For every trine, it represents a triangle,
    // and for every numeric value, they are the vertex index.
    // In this example, it constructs a cube:
    const vertex_indices = [_]app.gl.ushort{
        // These are for the original cube shape
        0, 1, 2,
        2, 1, 3,
        2, 3, 4,
        4, 3, 5,
        4, 5, 6,
        6, 5, 7,
        6, 7, 0,
        0, 7, 1,
        6, 0, 2,
        2, 4, 6,
        7, 5, 3,
        7, 3, 1,
        // The following will print a "Z" shape
        // 0, 1, 2,
        // 2, 1, 3,
        // 0, 1, 4,
        // 1, 4, 5,
        // 4, 5, 6,
        // 6, 5, 7,
    };

    // NEW: generate buffers for all the vertices with their positions
    // which in this case, we need two buffers to comply our two
    // newly added matrix.

    // creating a new buffer usually following the following pattern:
    app.gl.GenBuffers(1, (&position_buffer)[0..1]);
    app.gl.BindBuffer(app.gl.ARRAY_BUFFER, position_buffer);
    app.gl.BufferData(
        app.gl.ARRAY_BUFFER,
        @sizeOf(f32) * vertex_positions.len,
        &vertex_positions,
        app.gl.STATIC_DRAW,
    );

    // set up a vertex attribute array
    app.gl.EnableVertexAttribArray(0);
    app.gl.VertexAttribPointer(0, 3, app.gl.FLOAT, app.gl.FALSE, 0, 0);

    // the vertex index array buffer
    app.gl.GenBuffers(1, (&index_buffer)[0..1]);
    app.gl.BindBuffer(app.gl.ELEMENT_ARRAY_BUFFER, index_buffer);
    app.gl.BufferData(
        app.gl.ELEMENT_ARRAY_BUFFER,
        // @sizeOf(app.gl.ushort) * vertex_indices.len,
        @sizeOf(@TypeOf(vertex_indices)),
        &vertex_indices,
        app.gl.STATIC_DRAW,
    );

    // the following enables and disables the specified GL features
    app.gl.Enable(app.gl.CULL_FACE); // discard supposedly back facing triangles
    app.gl.Enable(app.gl.DEPTH_TEST);
    app.gl.Enable(app.gl.LEQUAL);
}

fn render(current_time: f64) callconv(.c) void {
    const green: [4]app.gl.float = .{ 0.0, 0.25, 0.0, 1.0 };
    const one: app.gl.float = 1.0;

    app.gl.Viewport(0, 0, app.info.windowWidth, app.info.windowHeight);
    app.gl.ClearBufferfv(app.gl.COLOR, 0, &green);
    app.gl.ClearBufferfv(app.gl.DEPTH, 0, (&one)[0..1]);

    app.gl.UseProgram(program);

    const proj_matrix = zm.Mat4f.perspective(
        std.math.degreesToRadians(50),
        @as(f32, @floatFromInt(app.info.windowWidth)) / @as(f32, @floatFromInt(app.info.windowHeight)),
        0.1,
        1000,
    );

    // zm is a row major matrix, while OpenGL is column major, so we need to transpose the matrix
    // by setting the transpose to app.gl.TRUE such that OpenGL can read the matrix properly;
    // otherwise, the rendering will completely messed up.
    app.gl.UniformMatrix4fv(proj_location, 1, app.gl.TRUE, @ptrCast(&proj_matrix));

    // This is a bad practice because MANY_CUBES is a boolean which is a predefined constant,
    // leading to dead codes which will never be executed in the runtime.
    if (MANY_CUBES) {
        for (0..24) |i| {
            const current_time_f32 = @as(f32, @floatCast(current_time));
            const f = @as(f32, @floatFromInt(i)) + current_time_f32 * 0.3;

            var mv_matrix = zm.Mat4f.translation(
                0.0,
                0.0,
                -20.0,
            );
            const mv_b = zm.Mat4f.rotation(
                zm.Vec3{ 0.0, 1.0, 0.0 },
                std.math.degreesToRadians(45 * current_time_f32),
            );
            const mv_c = zm.Mat4f.rotation(
                zm.Vec3{ 1.0, 0.0, 0.0 },
                std.math.degreesToRadians(21 * current_time_f32),
            );
            const mv_d = zm.Mat4f.translation(
                @sin(2.1 * f) * 2,
                @cos(1.7 * f) * 2,
                @sin(1.3 * f) * @cos(1.5 * f) * 2.0,
            );

            mv_matrix = mv_matrix.multiply(mv_b.multiply(mv_c.multiply(mv_d)));

            app.gl.UniformMatrix4fv(mv_location, 1, app.gl.TRUE, @ptrCast(&mv_matrix));
            app.gl.DrawElements(app.gl.TRIANGLES, 36, app.gl.UNSIGNED_SHORT, 0);
        }
    } else {
        // just do the one cube example first
        const current_time_f32 = @as(f32, @floatCast(current_time));
        const f = current_time_f32 * 0.3;

        var mv_matrix = zm.Mat4f.translation(0.0, 0.0, -4.0);
        const mv_b = zm.Mat4f.translation(
            @sin(2.1 * f) * 0.5,
            @cos(1.7 * f) * 0.5,
            @sin(1.3 * f) * @cos(1.5 * f) * 2.0,
        );
        const mv_c = zm.Mat4f.rotation(
            zm.Vec3f{ 0.0, 1.0, 0.0 },
            std.math.degreesToRadians(current_time_f32 * 45.0),
        );
        const mv_d = zm.Mat4f.rotation(
            zm.Vec3f{ 1.0, 0.0, 0.0 },
            std.math.degreesToRadians(current_time_f32 * 81.0),
        );

        mv_matrix = mv_matrix.multiply(mv_b.multiply(mv_c.multiply(mv_d)));

        app.gl.UniformMatrix4fv(mv_location, 1, app.gl.TRUE, @ptrCast(&mv_matrix));
        app.gl.DrawElements(app.gl.TRIANGLES, 36, app.gl.UNSIGNED_SHORT, 0);
    }
}

fn shutdown() callconv(.c) void {
    app.gl.BindVertexArray(0);
    app.gl.DeleteVertexArrays(1, (&vao)[0..1]);
    app.gl.DeleteProgram(program);
}
