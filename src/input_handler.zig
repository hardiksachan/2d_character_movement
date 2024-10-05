const rl = @import("raylib");

pub const Command = struct {
    pub const Value = enum(u2) {
        Left,
        Right,
        Jump,

        fn mask(self: *const Value) u32 {
            return @as(u32, 1) << @intFromEnum(self.*);
        }
    };

    composite: u32 = 0,

    pub fn is(self: *const Command, value: Value) bool {
        return self.composite & value.mask() > 0;
    }

    pub fn toggle(self: *Command, value: Value) void {
        self.composite |= value.mask();
    }
};

pub const InputHandler = struct {
    pub fn handleInput(self: *const InputHandler) Command {
        var command = Command{};

        if (self.left() and !self.right()) {
            command.toggle(Command.Value.Left);
        }
        if (self.right() and !self.left()) {
            command.toggle(Command.Value.Right);
        }
        if (self.jump()) {
            command.toggle(Command.Value.Jump);
        }

        return command;
    }

    fn left(_: *const InputHandler) bool {
        return rl.isKeyDown(rl.KeyboardKey.key_left) or rl.isKeyDown(rl.KeyboardKey.key_a);
    }

    fn right(_: *const InputHandler) bool {
        return rl.isKeyDown(rl.KeyboardKey.key_right) or rl.isKeyDown(rl.KeyboardKey.key_d);
    }

    fn jump(_: *const InputHandler) bool {
        return rl.isKeyDown(rl.KeyboardKey.key_space);
    }
};
