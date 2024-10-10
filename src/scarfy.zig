const rl = @import("raylib");

const Command = @import("input_handler.zig").Command;
const GroundWalker = @import("actors/ground_walker.zig").GroundWalker;

const gravity: f32 = 7.0;

pub const Scarfy = struct {
    walker: GroundWalker,
    sprite: ScarfySprite,
    audio: ScarfyAudio,

    ground_y: f32,

    pub fn new() Scarfy {
        const texture = rl.loadTexture("resources/scarfy.png");
        const frames = .{
            .count = 6,
            .current = 0,
            .delay_counter = 0,
            .delay = 6,
            .stationary = 2,
            .jump_up = 3,
            .jump_down = 4,
            .ground = (&[_]i32{ 1, 4 }),
        };
        const sprite = ScarfySprite.new(texture, frames);
        const walker = GroundWalker.new(5, 10, 0.5);
        const a = ScarfyAudio.new();

        return .{
            .walker = walker,
            .sprite = sprite,
            .audio = a,
            .ground_y = 0.75 * @as(f32, @floatFromInt(rl.getScreenHeight())),
        };
    }

    pub fn destory(self: *Scarfy) void {
        self.sprite.destroy();
    }

    pub fn update(self: *Scarfy, command: Command) void {
        self.walker.handleCommand(command, self.grounded());
        self.sprite.animate(self.walker.velocity);
    }

    pub fn draw(self: *Scarfy) void {
        self.sprite.draw(self.walker.position);
        self.audio.play(self.grounded(), self.walker.velocity, self.sprite.isGroundFrame());
    }

    pub fn audio(self: *const Scarfy) void {
        if (self.grounded() and !self.was_grounded) {
            rl.playSound(self.landing_sound);
        } else if (self.grounded() and self.walker.velocity.x != 0) {
            for (self.sprite.frames.ground) |frame| {
                if (self.sprite.frames.current == frame) {
                    rl.playSound(self.footstep_sound);
                    break;
                }
            }
        }
    }

    fn grounded(self: *const Scarfy) bool {
        return self.walker.position.y + @as(f32, @floatFromInt(self.sprite.texture.height)) >= self.ground_y;
    }
};

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

pub const ScarfySprite = struct {
    texture: rl.Texture,
    frames: FrameMetadata,
    direction_multiplier: i32 = 1,

    pub fn new(texture: rl.Texture, frames: FrameMetadata) ScarfySprite {
        return .{ .texture = texture, .frames = frames };
    }

    pub fn destroy(self: *ScarfySprite) void {
        rl.unloadTexture(self.texture);
    }

    pub fn animate(self: *ScarfySprite, velocity: rl.Vector2) void {
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

    pub fn draw(self: *const ScarfySprite, position: rl.Vector2) void {
        const frame_width = @divTrunc(@as(i32, self.texture.width), self.frames.count);
        const source_rec = rl.Rectangle{
            .x = @as(f32, @floatFromInt(frame_width * self.frames.current)),
            .y = 0,
            .width = @as(f32, @floatFromInt(self.direction_multiplier * frame_width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };
        rl.drawTextureRec(self.texture, source_rec, position, rl.Color.white);
    }

    pub fn isGroundFrame(self: *const ScarfySprite) bool {
        for (self.frames.ground) |frame| {
            if (self.frames.current == frame) {
                return true;
            }
        }
        return false;
    }
};

const ScarfyAudio = struct {
    footstep: rl.Sound,
    landing: rl.Sound,

    was_grounded: bool = false,

    pub fn new() ScarfyAudio {
        return .{
            .footstep = rl.loadSound("resources/footstep.mp3"),
            .landing = rl.loadSound("resources/landing.mp3"),
        };
    }

    pub fn play(self: *ScarfyAudio, on_ground: bool, velocity: rl.Vector2, is_ground_frame: bool) void {
        if (on_ground and !self.was_grounded) {
            rl.playSound(self.landing);
        } else if (on_ground and velocity.x != 0 and is_ground_frame) {
            rl.playSound(self.footstep);
        }

        self.was_grounded = on_ground;
    }

    pub fn destroy(self: *ScarfyAudio) void {
        rl.unloadSound(self.footstep);
        rl.unloadSound(self.landing);
    }
};
