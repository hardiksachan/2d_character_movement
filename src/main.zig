const rl = @import("raylib");
const InputHandler = @import("input_handler.zig").InputHandler;
const Scarfy = @import("scarfy.zig").Scarfy;

pub fn main() !void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.initWindow(screenWidth, screenHeight, "Platformer");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);

    const input_handler = InputHandler{};

    var scarfy = Scarfy.new();
    defer scarfy.destory();

    while (!rl.windowShouldClose()) {
        scarfy.update(input_handler.handleInput());

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        scarfy.draw();
    }
}
