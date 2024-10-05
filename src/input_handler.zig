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

pub fn handleInput() Command {
    var command = Command{};

    if (left() and !right()) {
        command.toggle(Command.Value.Left);
    }
    if (right() and !left()) {
        command.toggle(Command.Value.Right);
    }
    if (jump()) {
        command.toggle(Command.Value.Jump);
    }

    return command;
}

fn left() bool {
    return rl.isKeyDown(rl.KeyboardKey.key_left) or rl.isKeyDown(rl.KeyboardKey.key_a);
}

fn right() bool {
    return rl.isKeyDown(rl.KeyboardKey.key_right) or rl.isKeyDown(rl.KeyboardKey.key_d);
}

fn jump() bool {
    return rl.isKeyDown(rl.KeyboardKey.key_space);
}
