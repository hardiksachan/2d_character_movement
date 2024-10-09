const rl = @import("raylib");

const Command = @import("input_handler.zig").Command;
const GroundWalker = @import("ground_walker.zig").GroundWalker;
const AnimatedSprite = @import("sprite.zig").AnimatedSprite;

const gravity: f32 = 7.0;

pub const Scarfy = struct {
    walker: GroundWalker,
    sprite: AnimatedSprite,

    footstep_sound: rl.Sound,
    landing_sound: rl.Sound,
    ground_y: f32,

    was_grounded: bool = false,

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
        const sprite = AnimatedSprite.new(texture, frames);
        const walker = GroundWalker.new(5, 10, 0.5);

        return .{
            .walker = walker,
            .sprite = sprite,
            .footstep_sound = rl.loadSound("resources/footstep.mp3"),
            .landing_sound = rl.loadSound("resources/landing.mp3"),
            .ground_y = 0.75 * @as(f32, @floatFromInt(rl.getScreenHeight())),
        };
    }

    pub fn handleCommand(self: *Scarfy, command: Command) void {
        self.was_grounded = self.grounded();
        self.walker.handleCommand(command, self.grounded());
        self.sprite.animate(self.walker.velocity);
    }

    pub fn draw(self: *Scarfy) void {
        self.sprite.draw(self.walker.position);
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

    pub fn destory(self: *Scarfy) void {
        self.sprite.destroy();

        rl.unloadSound(self.footstep_sound);
        rl.unloadSound(self.landing_sound);
    }

    fn grounded(self: *const Scarfy) bool {
        return self.walker.position.y + @as(f32, @floatFromInt(self.sprite.texture.height)) >= self.ground_y;
    }
};
