# Warning:
The original intention of this project is to port the original C++ implementation of the OpenGL SuperBible into zig that is compatible with the book format so that I can learn about the main features of the OpenGL with minimal friction going through the book, which shows the **main features of the gl library** and the **shader code**, but because of objects and inheritance being forbidden in zig, I have to use function pointers as an alternative.

This is a **strongly discouraged practice** because the idea of zig is to minimizing the hidden behavior, writing in a more directed way, and I also dissatisfied with this current implementation; however, for the time I have, porting sb7.h directly is a more efficient approach to learn from the gl example, so I don't really have a choice for now. My project other than superbible won't write like this, please don't copy the structure.

If you are not focusing on the shader and the gl part of the library, you **SHOULD** take other projects as an reference to set up your opengl with is corresponding windowing system with a more idiomatic way:

- https://github.com/Logickin-Lambda/learn_opengl_first_triangle/blob/main/src/main.zig
- https://github.com/castholm/zig-examples/tree/master/opengl-hexagon
- https://github.com/griush/zig-opengl-example/blob/master/src/main.zig

# This is the next step after a triangle

After I have plotted an triangle, and able to how to take use OpenGL with zig and its dependencies, I decided to a step further with porting the sb7.h from the OpenGL Superbible 7th edition so that I can use zig to learn from the book and trying to figuring how to port code with OOP concept into zig with similar workflow. If I have a working framework, I will separate it from my current project for other future learning project.

Besides, I am trying to replicate the **indexedcube** example from the superbible, to learn about how the vao (vertex array object) and vbo (vertex buffer object) work.