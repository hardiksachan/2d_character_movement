const rl = @import("raylib");

const Command = @import("../input_handler.zig").Command;
const GroundWalker = @import("../physics/ground_walker.zig").GroundWalker;

const gravity: f32 = 7.0;

pub const Scarfy = struct {
    walker: GroundWalker,
    sprite: ScarfySprite,
    audio: ScarfyAudio,

    was_grounded: bool = false,
    on_ground: bool = false,

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
            .was_grounded = false,
            .on_ground = false,
        };
    }

    pub fn destroy(ctx: *anyopaque) void {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        self.sprite.destroy();
    }

    pub fn update(ctx: *anyopaque, command: Command, on_ground: bool) void {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        self.was_grounded = self.on_ground;
        self.on_ground = on_ground;

        self.walker.handleCommand(command, on_ground);
        self.sprite.animate(self.walker.velocity);
    }

    pub fn draw(ctx: *anyopaque) void {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        self.sprite.draw(self.walker.position);
    }

    pub fn audio(ctx: *anyopaque) void {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        self.audio.play(self.was_grounded, self.on_ground, self.walker.velocity, self.sprite.isGroundFrame());
    }

    pub fn position(ctx: *anyopaque) rl.Vector2 {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        return self.walker.position;
    }

    pub fn velocity(ctx: *anyopaque) rl.Vector2 {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        return self.walker.velocity;
    }

    pub fn boundingBox(ctx: *anyopaque) rl.Rectangle {
        const self: *Scarfy = @ptrCast(@alignCast(ctx));

        const ulPosition = self.upperLeftPosition();
        const frame_size = self.sprite.frameSize();
        return rl.Rectangle{
            .x = ulPosition.x,
            .y = ulPosition.y,
            .width = frame_size.x,
            .height = frame_size.y,
        };
    }

    fn upperLeftPosition(self: *Scarfy) rl.Vector2 {
        const frame_size = self.sprite.frameSize();
        return rl.Vector2{
            .x = self.walker.position.x - frame_size.x / 2,
            .y = self.walker.position.y - frame_size.y,
        };
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

    pub fn frameSize(self: *const ScarfySprite) rl.Vector2 {
        return rl.Vector2{
            .x = @as(f32, @floatFromInt(@divTrunc(@as(i32, self.texture.width), self.frames.count))),
            .y = @as(f32, @floatFromInt(self.texture.height)),
        };
    }
};

const ScarfyAudio = struct {
    footstep: rl.Sound,
    landing: rl.Sound,

    pub fn new() ScarfyAudio {
        return .{
            .footstep = rl.loadSound("resources/footstep.mp3"),
            .landing = rl.loadSound("resources/landing.mp3"),
        };
    }

    pub fn play(self: *ScarfyAudio, was_grounded: bool, on_ground: bool, velocity: rl.Vector2, is_ground_frame: bool) void {
        if (on_ground and !was_grounded) {
            rl.playSound(self.landing);
        } else if (on_ground and velocity.x != 0 and is_ground_frame) {
            rl.playSound(self.footstep);
        }
    }

    pub fn destroy(self: *ScarfyAudio) void {
        rl.unloadSound(self.footstep);
        rl.unloadSound(self.landing);
    }
};
