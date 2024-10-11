const rl = @import("raylib");
const InputHandler = @import("input_handler.zig").InputHandler;
const Scarfy = @import("actors/scarfy.zig").Scarfy;
const Actor = @import("actors/actor.zig").Actor;

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
    var actor = Actor.from(&scarfy, Scarfy);
    defer actor.destroy();

    while (!rl.windowShouldClose()) {
        actor.update(input_handler.handleInput(), true);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        actor.draw();
        actor.audio();
    }
}
