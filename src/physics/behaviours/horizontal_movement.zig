const rl = @import("raylib");

pub const HorizontalMovement = struct {
    speed: f32,

    pub fn new(speed: f32) HorizontalMovement {
        return .{ .speed = speed };
    }

    pub fn left(self: *HorizontalMovement, velocity: *rl.Vector2) void {
        velocity.x = -self.speed;
    }

    pub fn right(self: *HorizontalMovement, velocity: *rl.Vector2) void {
        velocity.x = self.speed;
    }

    pub fn stop(_: *HorizontalMovement, velocity: *rl.Vector2) void {
        velocity.x = 0;
    }
};
