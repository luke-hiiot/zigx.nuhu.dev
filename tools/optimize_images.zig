const std = @import("std");
const image_optimizer = @import("../src/image_optimizer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator;

    // Get the image directory path from command line arguments or default to "site/assets/images"
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const img_dir_path = if (args.len > 1) args[1] else "site/assets/images";

    std.debug.print("Optimizing images in directory: {s}\n", .{img_dir_path});
    
    try processImageDirectory(allocator, img_dir_path);
}

fn processImageDirectory(allocator: std.mem.Allocator, img_dir_path: []const u8) !void {
    var dir = std.fs.cwd().openDir(img_dir_path, .{}) catch |err| {
        std.debug.print("Error opening image directory {s}: {any}\n", .{ img_dir_path, err });
        // If the directory doesn't exist, that's fine, just exit gracefully
        return;
    };
    defer dir.close();

    // Create optimized images directory if it doesn't exist
    try ensureDirExists(allocator, "site/assets/images/optimized");

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    var optimizer = image_optimizer.ImageOptimizer.init(allocator);

    while (try walker.next()) |entry| {
        if (entry.kind == .file and isImageFile(entry.basename)) {
            const input_path = try std.fs.path.join(allocator, &[_][]const u8{ img_dir_path, entry.path });
            defer allocator.free(input_path);

            // Create optimized version
            const output_path = try std.fs.path.join(allocator, &[_][]const u8{ "site/assets/images/optimized", entry.path });
            defer allocator.free(output_path);

            std.debug.print("Optimizing image: {s}\n", .{input_path});

            // Ensure output directory exists
            const output_dir = std.fs.path.dirname(output_path).?;
            try ensureDirExists(allocator, output_dir);

            // Optimize the image with default options
            const options = image_optimizer.OptimizeOptions{
                .quality = 80,
                .format = null,
            };

            try optimizer.optimize(input_path, output_path, options);

            std.debug.print("Optimized image saved to: {s}\n", .{output_path});
        }
    }
}

fn isImageFile(filename: []const u8) bool {
    const lower_filename = std.ascii.lowerStringAlloc(std.heap.page_allocator, filename) catch return false;
    defer std.heap.page_allocator.free(lower_filename);
    
    return std.mem.endsWith(u8, lower_filename, ".jpg") or
           std.mem.endsWith(u8, lower_filename, ".jpeg") or
           std.mem.endsWith(u8, lower_filename, ".png") or
           std.mem.endsWith(u8, lower_filename, ".gif") or
           std.mem.endsWith(u8, lower_filename, ".webp") or
           std.mem.endsWith(u8, lower_filename, ".avif");
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