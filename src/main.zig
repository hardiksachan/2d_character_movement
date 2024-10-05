const rl = @import("raylib");
const Scarfy = @import("scarfy.zig").Scarfy;
const InputHandler = @import("input_handler.zig");

pub fn main() !void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.initWindow(screenWidth, screenHeight, "Platformer");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);

    var scarfy = Scarfy{};
    scarfy.init();
    defer scarfy.close();

    while (!rl.windowShouldClose()) {
        scarfy.update(InputHandler.handleInput());

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        scarfy.draw();
        scarfy.audio();
    }
}
