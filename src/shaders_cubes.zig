// This is actually not the idiomatic way to write shaders which they have
// their own file format, but to prevent the main program too cluttered,
// let me locate the shaders in here.

/// Vertex Shader, plotting the location of the vertices.
///
/// The program breakdown is the following:
///
/// #verision 430 core                          <- defining the OpenGl Version
///
/// in vec4 position;                           <- defining the input
///
/// out VS_OUT{                                 <- defining a struct (aka interface block) for output
///     vec4 color;                                which in this case, the struct
/// } vs_out;                                      contains a vec4 for color
///
/// uniform mat4 mv_matrix                      <- uniforms are data type that shared for all shader program
/// uniform mat4 proj_matrix                       and they are immutable in the shader level. They are useful
///                                                to transform objects in a bulk with the same unified values.
///
/// void main(void)                             <- take the incoming vertex and transform it based on the
/// {                                              two given uniform matrix.
///     gl_Position = proj_matrix * mv_matrix * position;
///     vs_out.color = position * 2.0 + vec4(0.5, 0.5, 0.5, 0.0);
/// }
pub const vertexShaderImpl =
    \\ #version 450 core
    \\
    \\ in vec4 position;
    \\
    \\ out VS_OUT
    \\ {
    \\      vec4 color;
    \\ } vs_out;
    \\
    \\ uniform mat4 mv_matrix
    \\ uniform mat4 proj_matrix
    \\
    \\ void main (void)
    \\ {
    \\      gl_Position = proj_matrix * mv_matrix * position;
    \\      vs_out.color = position * 2.0 + vec4(0.5, 0.5, 0.5, 0.0);
    \\ }
;

/// fragment Shader, changing the color of the the geometries
pub const fragmentShaderImpl =
    \\ #version 450 core
    \\
    \\ out vec4 color;
    \\
    \\ in VS_OUT
    \\ {
    \\      vec4 color;   
    \\ } fs_in;
    \\ 
    \\ void main(void)
    \\ {
    \\      color = fs_in.color;
    \\ }
;
