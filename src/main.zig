const rl = @import("raylib");

const ScarfyDirection = enum(i32) {
    Right = 1,
    Left = -1,
};

const Scarfy = struct {
    texture: rl.Texture = undefined,

    scarfy_walk_speed: f32 = 6.0,

    frame_count: i32 = 6,
    frame_index: i32 = 0,
    frame_delay_counter: i32 = 0,
    frame_delay: i32 = 6,

    direction: ScarfyDirection = ScarfyDirection.Right,
    scarfy_position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },

    pub fn init(self: *Scarfy) void {
        self.texture = rl.loadTexture("resources/scarfy.png");
    }

    pub fn update(self: *Scarfy) void {
        if (rl.isKeyDown(rl.KeyboardKey.key_right) and !rl.isKeyDown(rl.KeyboardKey.key_left)) {
            self.direction = ScarfyDirection.Right;
            self.scarfy_position.x += self.scarfy_walk_speed;
            self.animate();
        } else if (rl.isKeyDown(rl.KeyboardKey.key_left) and !rl.isKeyDown(rl.KeyboardKey.key_right)) {
            self.direction = ScarfyDirection.Left;
            self.scarfy_position.x -= self.scarfy_walk_speed;
            self.animate();
        } else {
            self.frame_index = 2;
        }
    }

    pub fn draw(self: *const Scarfy) void {
        const frame_width = @divTrunc(@as(i32, self.texture.width), self.frame_count);
        const source_rec = rl.Rectangle{
            .x = @as(f32, @floatFromInt(frame_width * self.frame_index)),
            .y = 0,
            .width = @as(f32, @floatFromInt(@intFromEnum(self.direction) * frame_width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };

        rl.drawTextureRec(
            self.texture,
            source_rec,
            self.scarfy_position,
            rl.Color.white,
        );
    }

    fn animate(self: *Scarfy) void {
        self.frame_delay_counter += 1;
        if (self.frame_delay_counter >= self.frame_delay) {
            self.frame_delay_counter = 0;
            self.frame_index += 1;
        }
        if (self.frame_index >= self.frame_count) {
            self.frame_index = 0;
        }
    }

    fn deinit(self: *Scarfy) void {
        rl.unloadTexture(self.texture);
    }
};

pub fn main() !void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.initWindow(screenWidth, screenHeight, "Platformer");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var scarfy = Scarfy{};
    scarfy.init();
    defer scarfy.deinit();

    while (!rl.windowShouldClose()) {
        scarfy.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);

        scarfy.draw();
    }
}
