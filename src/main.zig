const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(750, 700, "Zpace invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(rl.KeyboardKey.null);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
    }
}
