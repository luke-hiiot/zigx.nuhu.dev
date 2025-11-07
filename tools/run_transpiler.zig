const std = @import("std");
const Transpiler = @import("zx/src/zx/Transpiler_prototype.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator;

    // Get the directory path from command line arguments or default to "site"
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const dir_path = if (args.len > 1) args[1] else "site";

    try processDirectory(allocator, dir_path);
}

fn processDirectory(allocator: std.mem.Allocator, dir_path: []const u8) !void {
    var dir = std.fs.cwd().openDir(dir_path, .{}) catch |err| {
        std.debug.print("Error opening directory {s}: {any}\n", .{ dir_path, err });
        return;
    };
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.basename, ".zx")) {
            // Create output file path by replacing .zx with .zig
            const input_path = try std.fs.path.join(allocator, &[_][]const u8{ dir_path, entry.path });
            defer allocator.free(input_path);

            // Change extension from .zx to .zig
            const output_path = try std.mem.replaceOwned(u8, allocator, input_path, ".zx", ".zig");
            defer allocator.free(output_path);

            std.debug.print("Processing {s} -> {s}\n", .{ input_path, output_path });

            // Ensure the output directory exists
            const output_dir = std.fs.path.dirname(output_path).?;
            try ensureDirExists(allocator, output_dir);

            // Transpile the file using the proper transpiler
            try transpileFile(allocator, input_path, output_path);

            std.debug.print("Successfully transpiled {s}\n", .{input_path});
        }
    }
}

fn ensureDirExists(allocator: std.mem.Allocator, dir_path: []const u8) !void {
    // Split the path and create directories recursively
    var parts = std.ArrayList([]const u8).init(allocator);
    defer parts.deinit();

    var iter = std.mem.splitScalar(u8, dir_path, std.fs.path.sep);
    while (iter.next()) |part| {
        if (part.len > 0) {
            try parts.append(part);
        }
    }

    var current_path = std.ArrayList(u8).init(allocator);
    defer current_path.deinit();

    for (parts.items) |part| {
        if (current_path.items.len > 0) {
            try current_path.append(std.fs.path.sep);
        }
        try current_path.appendSlice(part);

        // Try to create the directory
        std.fs.cwd().makeDir(current_path.items) catch |err| {
            // If it already exists, that's fine
            if (err != error.PathAlreadyExists) {
                return err;
            }
        };
    }
}

fn transpileFile(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Read the input file
    const input_content = try std.fs.cwd().readFileAlloc(allocator, input_path, 10 * 1024 * 1024); // 10MB max
    defer allocator.free(input_content);

    // Use the transpiler to convert JSX to zig code
    const transpiled_content = try Transpiler.transpile(allocator, input_content);
    defer allocator.free(transpiled_content);

    // Write the output file
    try std.fs.cwd().writeFile(output_path, transpiled_content);
}