const rl = @import("raylib");
const Command = @import("../input_handler.zig").Command;

pub const Actor = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    pub const Interface = struct {
        update: *const fn (ctx: *anyopaque, command: Command, on_ground: bool) void,
        draw: *const fn (ctx: *anyopaque) void,
        audio: *const fn (ctx: *anyopaque) void,
        destroy: *const fn (ctx: *anyopaque) void,
        position: *const fn (ctx: *anyopaque) rl.Vector2,
        velocity: *const fn (ctx: *anyopaque) rl.Vector2,
        boundingBox: *const fn (ctx: *anyopaque) rl.Rectangle,
    };

    pub fn from(ctx: *anyopaque, comptime T: type) Actor {
        const self: *T = @ptrCast(@alignCast(ctx));
        return Actor{
            .ptr = self,
            .impl = &.{
                .draw = T.draw,
                .audio = T.audio,
                .update = T.update,
                .destroy = T.destroy,
                .position = T.position,
                .velocity = T.velocity,
                .boundingBox = T.boundingBox,
            },
        };
    }

    pub fn update(self: *Actor, command: Command, on_ground: bool) void {
        self.impl.update(self.ptr, command, on_ground);
    }

    pub fn draw(self: *Actor) void {
        self.impl.draw(self.ptr);
    }

    pub fn audio(self: *Actor) void {
        self.impl.audio(self.ptr);
    }

    pub fn position(self: *Actor) rl.Vector2 {
        return self.impl.position(self.ptr);
    }

    pub fn velocity(self: *Actor) rl.Vector2 {
        return self.impl.velocity(self.ptr);
    }

    pub fn boundingBox(self: *Actor) rl.Rectangle {
        return self.impl.boundingBox(self.ptr);
    }

    pub fn destroy(self: *Actor) void {
        self.impl.destroy(self.ptr);
    }
};
