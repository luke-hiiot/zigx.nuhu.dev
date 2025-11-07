const std = @import("std");
const image_optimizer = @import("image_optimizer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 从命令行参数获取图像目录路径，默认为 "site/assets/images"
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const img_dir_path = if (args.len > 1) args[1] else "site/assets/images";

    std.debug.print("正在优化目录中的图像: {s}\n", .{img_dir_path});
    
    // 如果不存在则创建优化图像目录
    _ = std.fs.cwd().makeDir("site/assets/images/optimized") catch |err| {
        if (err != error.PathAlreadyExists) {
            std.debug.print("创建优化图像目录时出错: {any}\n", .{err});
        }
    };

    // 尝试打开图像目录
    var dir = std.fs.cwd().openDir(img_dir_path, .{}) catch |err| {
        std.debug.print("图像目录 {s} 不存在，跳过图像优化: {any}\n", .{ img_dir_path, err });
        // 如果目录不存在，也没关系，正常退出
        return;
    };
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    var optimizer = image_optimizer.ImageOptimizer.init(allocator);

    while (try walker.next()) |entry| {
        if (entry.kind == .file and isImageFile(entry.basename)) {
            const input_path = try std.fs.path.join(allocator, &[_][]const u8{ img_dir_path, entry.path });
            defer allocator.free(input_path);

            // 创建优化版本
            const output_path = try std.fs.path.join(allocator, &[_][]const u8{ "site/assets/images/optimized", entry.path });
            defer allocator.free(output_path);

            std.debug.print("正在优化图像: {s}\n", .{input_path});

            // 确保输出目录存在
            const output_dir = std.fs.path.dirname(output_path) orelse continue;
            _ = output_dir; // 只是确认变量已使用

            // 使用默认选项优化图像
            const options = image_optimizer.OptimizeOptions{
                .quality = 80,
                .format = null,
            };

            try optimizer.optimize(input_path, output_path, options);

            std.debug.print("优化后的图像已保存到: {s}\n", .{output_path});
        }
    }
}

fn isImageFile(filename: []const u8) bool {
    // 检查文件扩展名（不区分大小写）
    if (filename.len < 4) return false;
    
    // 检查常见图像扩展名 - 手动比较，不使用 lowerStringAlloc
    var i: usize = if (filename.len >= 4) filename.len - 4 else 0;
    while (i < filename.len) : (i += 1) {
        if (std.ascii.toLower(filename[i]) == 'j' and 
            i + 3 < filename.len and
            std.ascii.toLower(filename[i + 1]) == 'p' and
            std.ascii.toLower(filename[i + 2]) == 'g') {
            return true;
        }
    }
    
    // 检查 .jpeg
    if (filename.len >= 5) {
        i = filename.len - 5;
        if (std.ascii.toLower(filename[i]) == '.' and
            std.ascii.toLower(filename[i + 1]) == 'j' and
            std.ascii.toLower(filename[i + 2]) == 'p' and
            std.ascii.toLower(filename[i + 3]) == 'e' and
            std.ascii.toLower(filename[i + 4]) == 'g') {
            return true;
        }
    }
    
    // 检查 .png
    if (filename.len >= 4) {
        i = filename.len - 4;
        if (std.ascii.toLower(filename[i]) == 'p' and
            std.ascii.toLower(filename[i + 1]) == 'n' and
            std.ascii.toLower(filename[i + 2]) == 'g') {
            return true;
        }
    }
    
    // 检查 .gif
    if (filename.len >= 4) {
        i = filename.len - 4;
        if (std.ascii.toLower(filename[i]) == 'g' and
            std.ascii.toLower(filename[i + 1]) == 'i' and
            std.ascii.toLower(filename[i + 2]) == 'f') {
            return true;
        }
    }
    
    // 检查 .webp
    if (filename.len >= 5) {
        i = filename.len - 5;
        if (std.ascii.toLower(filename[i]) == 'w' and
            std.ascii.toLower(filename[i + 1]) == 'e' and
            std.ascii.toLower(filename[i + 2]) == 'b' and
            std.ascii.toLower(filename[i + 3]) == 'p') {
            return true;
        }
    }
    
    // 检查 .avif
    if (filename.len >= 5) {
        i = filename.len - 5;
        if (std.ascii.toLower(filename[i]) == 'a' and
            std.ascii.toLower(filename[i + 1]) == 'v' and
            std.ascii.toLower(filename[i + 2]) == 'i' and
            std.ascii.toLower(filename[i + 3]) == 'f') {
            return true;
        }
    }
    
    return false;
}