const rl = @import("raylib");

const Actor = @import("actor.zig").Actor;
const Command = @import("input_handler.zig").Command;

pub const Testy = struct {
    actor: Actor,

    pub fn new() Testy {
        return .{ .actor = Actor.new(5, 10, 0.5) };
    }

    pub fn handleCommand(self: *Testy, command: Command) void {
        self.actor.handleCommand(command, self.grounded());
    }

    pub fn draw(self: *Testy) void {
        rl.drawRectangleV(self.actor.position, .{ .x = 50, .y = 50 }, rl.Color.red);
    }

    fn grounded(self: *Testy) bool {
        return self.actor.position.y >= 600;
    }
};
