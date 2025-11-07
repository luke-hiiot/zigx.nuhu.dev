const Metadata = @import("meta.zig");
const std = @import("std");
const zx = @import("zx");

// 检查端口是否可用
fn isPortAvailable(port: u16) bool {
    const address = std.net.Address.parseIp("0.0.0.0", port) catch return false;
    const socket = std.posix.socket(std.posix.AF.INET, std.posix.SOCK.STREAM, 0) catch return false;
    defer std.posix.close(socket);

    // 设置 SO_REUSEADDR 选项
    std.posix.setsockopt(socket, std.posix.SOL.SOCKET, std.posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1))) catch {};
    
    // 尝试绑定到端口
    std.posix.bind(socket, &address.any, address.getOsSockLen()) catch |err| switch (err) {
        error.AddressInUse => return false, // 端口已被占用
        else => return true, // 其他错误可能表示端口可用
    };
    
    return true; // 成功绑定表示端口可用
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // 尝试从环境变量获取端口，如果未设置则使用默认值
    var default_port: u16 = 5882;
    const env_port = std.process.getEnvVarOwned(allocator, "ZX_PORT") catch null;
    if (env_port) |port_str| {
        default_port = std.fmt.parseInt(u16, port_str, 10) catch 5882;
        allocator.free(port_str);
    }

    // 尝试不同的端口直到找到一个可用的
    var port = default_port;
    var app: *zx.App = undefined;
    var attempts: u16 = 0;
    const max_attempts: u16 = 20; // 尝试最多20个端口

    while (attempts < max_attempts) : (attempts += 1) {
        if (!isPortAvailable(port)) {
            std.debug.print("端口 {d} 已被占用，尝试下一个端口...\n", .{port});
            port += 1;
            continue;
        }

        const config = zx.App.Config{
            .server = .{ .port = port, .address = "0.0.0.0" },
            .meta = &Metadata.meta,
            .hmr_enabled = true, // Enable HMR in development
        };

        std.debug.print("尝试启动服务器在端口: {d}\n", .{port});
        
        app = zx.App.init(allocator, config) catch |err| {
            std.debug.print("初始化服务器失败: {any}，尝试下一个端口...\n", .{err});
            port += 1;
            continue;
        };

        // 如果初始化成功，跳出循环
        break;
    }

    if (attempts >= max_attempts) {
        std.debug.print("错误: 无法在任何端口上启动服务器 (尝试了 {d} 个端口)\n", .{max_attempts});
        return error.CannotStartServer;
    }

    defer app.deinit();

    std.debug.print("{s}\n  - Local: http://localhost:{d}\n", .{ zx.App.info, port });
    try app.start();
}
