const rl = @import("raylib");
const Command = @import("../input_handler.zig").Command;

pub const Scene = struct {
    ptr: *anyopaque,
    impl: *const Interface,

    pub const Interface = struct {
        load: *const fn (ctx: *anyopaque) void,
        reset: *const fn (ctx: *anyopaque) void,
        update: *const fn (ctx: *anyopaque, command: Command, on_ground: bool) ?Scene,
        draw: *const fn (ctx: *anyopaque) void,
        audio: *const fn (ctx: *anyopaque) void,
        destroy: *const fn (ctx: *anyopaque) void,
    };

    pub fn from(ctx: *anyopaque, comptime T: type) Scene {
        const self: *T = @ptrCast(@alignCast(ctx));
        return Scene{
            .ptr = self,
            .impl = &.{
                .load = self.load,
                .update = T.update,
                .draw = T.draw,
                .audio = T.audio,
                .destroy = T.destroy,
            },
        };
    }

    pub fn load(self: *Scene) void {
        self.impl.load(self.ptr);
    }

    pub fn reset(self: *Scene) void {
        self.impl.reset(self.ptr);
    }

    pub fn update(self: *Scene, command: Command, on_ground: bool) void {
        self.impl.update(self.ptr, command, on_ground);
    }

    pub fn draw(self: *Scene) void {
        self.impl.draw(self.ptr);
    }

    pub fn audio(self: *Scene) void {
        self.impl.audio(self.ptr);
    }

    pub fn destroy(self: *Scene) void {
        self.impl.destroy(self.ptr);
    }
};
