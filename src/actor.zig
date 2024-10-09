const rl = @import("raylib");

const Command = @import("input_handler.zig").Command;

const HorizontalMovement = @import("physics/horizontal_movement.zig").HorizontalMovement;
const Gravity = @import("physics/gravity.zig").Gravity;
const Jump = @import("physics/jump.zig").Jump;

pub const Actor = struct {
    move: HorizontalMovement,
    gravity: Gravity,
    jump: Jump,

    position: rl.Vector2 = .{ .x = 0, .y = 0 },
    velocity: rl.Vector2 = .{ .x = 0, .y = 0 },

    pub fn new(walk_speed: f32, jump_impulse: f32, gravity: f32) Actor {
        return Actor{
            .move = HorizontalMovement{ .speed = walk_speed },
            .gravity = Gravity{ .gravity = gravity },
            .jump = Jump{ .impulse = jump_impulse },
        };
    }

    pub fn handleCommand(self: *Actor, command: Command, on_ground: bool) void {
        if (command.is(Command.Value.Jump)) {
            self.jump.apply(&self.velocity, on_ground);
        }

        if (on_ground) {
            if (command.is(Command.Value.Right)) {
                self.move.right(&self.velocity);
            } else if (command.is(Command.Value.Left)) {
                self.move.left(&self.velocity);
            } else {
                self.move.stop(&self.velocity);
            }
        }

        self.gravity.apply(&self.velocity, on_ground);

        self.position.x += self.velocity.x;
        self.position.y += self.velocity.y;
    }
};
