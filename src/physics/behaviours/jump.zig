const rl = @import("raylib");

pub const Jump = struct {
    impulse: f32,

    pub fn new(impulse: f32) Jump {
        return .{ .impulse = impulse };
    }

    pub fn apply(self: *Jump, velocity: *rl.Vector2, on_ground: bool) void {
        if (on_ground) {
            velocity.y = -self.impulse;
        }
    }
};
