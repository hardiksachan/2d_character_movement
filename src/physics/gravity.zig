const rl = @import("raylib");

pub const Gravity = struct {
    gravity: f32,

    pub fn new(gravity: f32) Gravity {
        return .{ .gravity = gravity };
    }

    pub fn apply(self: *Gravity, velocity: *rl.Vector2, on_ground: bool) void {
        if (on_ground) {
            if (velocity.y > 0) {
                velocity.y = 0;
            }
            return;
        }
        velocity.y += self.gravity;
    }
};
