const rl = @import("raylib");

const FrameMetadata = struct {
    count: i32,
    current: i32,
    delay_counter: i32,
    delay: i32,

    stationary: i32,
    jump_up: i32,
    jump_down: i32,

    ground: []const i32,
};

pub const AnimatedSprite = struct {
    texture: rl.Texture,
    frames: FrameMetadata,
    direction_multiplier: i32 = 1,

    pub fn new(texture: rl.Texture, frames: FrameMetadata) AnimatedSprite {
        return .{ .texture = texture, .frames = frames };
    }

    pub fn destroy(self: *AnimatedSprite) void {
        rl.unloadTexture(self.texture);
    }

    pub fn animate(self: *AnimatedSprite, velocity: rl.Vector2) void {
        if (velocity.x > 0) {
            self.direction_multiplier = 1;
        } else if (velocity.x < 0) {
            self.direction_multiplier = -1;
        } else if (velocity.x == 0) {
            self.frames.current = self.frames.stationary;
        }

        if (velocity.y > 0) {
            self.frames.current = self.frames.jump_up;
        } else if (velocity.y < 0) {
            self.frames.current = self.frames.jump_down;
        }

        if (velocity.y > 0 or velocity.y < 0 or velocity.x == 0) return;

        self.frames.delay_counter += 1;
        if (self.frames.delay_counter >= self.frames.delay) {
            self.frames.delay_counter = 0;
            self.frames.current += 1;
        }
        if (self.frames.current >= self.frames.count) {
            self.frames.current = 0;
        }
    }

    pub fn draw(self: *const AnimatedSprite, position: rl.Vector2) void {
        const frame_width = @divTrunc(@as(i32, self.texture.width), self.frames.count);
        const source_rec = rl.Rectangle{
            .x = @as(f32, @floatFromInt(frame_width * self.frames.current)),
            .y = 0,
            .width = @as(f32, @floatFromInt(self.direction_multiplier * frame_width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };
        rl.drawTextureRec(self.texture, source_rec, position, rl.Color.white);
    }
};
