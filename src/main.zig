const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants");
const entities = @import("entities");

const colors = constants.colors;
const ui = constants.ui;

pub fn main() !void {
    rl.initWindow(750 + ui.offset, 700 + 2 * ui.offset, "Zpace invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    rl.setExitKey(rl.KeyboardKey.null);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game = try entities.Game.init(allocator);
    defer game.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try game.handleInput();

        rl.clearBackground(colors.grey);
        rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(10, 10, 780, 780), 0.18, 20, 2, colors.yellow);

        game.draw();
        try game.update();
    }
}
