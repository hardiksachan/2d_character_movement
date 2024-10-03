const rl = @import("raylib");

const gravity: f32 = 7.0;

const Scarfy = struct {
    texture: rl.Texture = undefined,

    walk_speed: f32 = 6.0,
    jump_charge_max: f32 = 30.0,
    jump_decay_factor: f32 = 0.4,

    frame_count: i32 = 6,
    frame_index: i32 = 0,
    frame_delay_counter: i32 = 0,
    frame_delay: i32 = 6,

    stationary_frame: i32 = 2,
    jump_up_frame: i32 = 3,
    jump_down_frame: i32 = 4,

    position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    velocity: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },

    ground_y: f32 = 0,
    direction_multiplier: i32 = 1,

    pub fn init(self: *Scarfy) void {
        self.texture = rl.loadTexture("resources/scarfy.png");
        self.ground_y = 0.75 * @as(f32, @floatFromInt(rl.getScreenHeight()));
    }

    pub fn update(self: *Scarfy) void {
        self.handleInput();
        self.applyPhysics();
        self.animate();
    }

    pub fn draw(self: *const Scarfy) void {
        self.drawScarfy();
        self.drawDebug();
    }

    fn drawScarfy(self: *const Scarfy) void {
        const frame_width = @divTrunc(@as(i32, self.texture.width), self.frame_count);
        const source_rec = rl.Rectangle{
            .x = @as(f32, @floatFromInt(frame_width * self.frame_index)),
            .y = 0,
            .width = @as(f32, @floatFromInt(self.direction_multiplier * frame_width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };

        rl.drawTextureRec(
            self.texture,
            source_rec,
            self.position,
            rl.Color.white,
        );
    }

    fn drawDebug(self: *const Scarfy) void {
        rl.drawRectangle(0, @intFromFloat(self.ground_y), rl.getScreenWidth(), 1, rl.Color.red);
        rl.drawRectangleLines(
            @intFromFloat(self.position.x),
            @intFromFloat(self.position.y),
            @intFromFloat(@as(f32, @floatFromInt(self.texture.width)) / 6.0),
            @intFromFloat(@as(f32, @floatFromInt(self.texture.height))),
            rl.Color.green,
        );
        const text_grounded = if (self.grounded()) "Grounded" else "Airborne";
        rl.drawText(text_grounded, 0, 0, 20, rl.Color.red);

        const text_jump_charge = rl.textFormat("Velocity | x = %.2f, y = %.2f", .{ self.velocity.x, self.velocity.y });
        rl.drawText(text_jump_charge, 0, 20, 20, rl.Color.red);
    }

    fn handleInput(self: *Scarfy) void {
        if (!self.grounded()) {
            return;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            self.velocity.y = self.jump_charge_max;
        }

        if (rl.isKeyDown(rl.KeyboardKey.key_right) and !rl.isKeyDown(rl.KeyboardKey.key_left)) {
            self.velocity.x = self.walk_speed;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_left) and !rl.isKeyDown(rl.KeyboardKey.key_right)) {
            self.velocity.x = -self.walk_speed;
        } else {
            self.velocity.x = 0;
        }
    }

    fn applyPhysics(self: *Scarfy) void {
        if (self.velocity.y > 0) {
            self.position.y -= self.velocity.y;
            self.velocity.y -= gravity * self.jump_decay_factor;
        } else if (!self.grounded()) {
            self.position.y += gravity;
        } else {
            self.velocity.y = 0;
        }
        self.position.x += self.velocity.x;
    }

    fn animate(self: *Scarfy) void {
        if (self.velocity.x > 0) {
            self.direction_multiplier = 1;
        } else if (self.velocity.x < 0) {
            self.direction_multiplier = -1;
        } else if (self.velocity.x == 0) {
            self.frame_index = self.stationary_frame;
        }

        if (self.velocity.y > 0) {
            self.frame_index = self.jump_up_frame;
        } else if (!self.grounded()) {
            self.frame_index = self.jump_down_frame;
        }

        if (self.velocity.y > 0 or !self.grounded() or self.velocity.x == 0) return;

        self.frame_delay_counter += 1;
        if (self.frame_delay_counter >= self.frame_delay) {
            self.frame_delay_counter = 0;
            self.frame_index += 1;
        }
        if (self.frame_index >= self.frame_count) {
            self.frame_index = 0;
        }
    }

    fn grounded(self: *const Scarfy) bool {
        return self.position.y + @as(f32, @floatFromInt(self.texture.height)) >= self.ground_y;
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
