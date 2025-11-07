// 具有优化功能的图像组件
pub fn OptimizedImage(allocator: zx.Allocator, props: OptimizedImageProps) zx.Component {
    _ = allocator;
    const _zx = zx.init(allocator);
    
    // 构建图像属性
    var attrs = std.ArrayList(zx.Element.Attribute).init(allocator);
    
    // 添加带有潜在优化参数的 src 属性
    const src_with_params = if (props.quality != 80) 
        try std.fmt.allocPrint(allocator, "{s}?q={d}", .{ props.src, props.quality })
    else 
        props.src;
    
    try attrs.append(.{ .name = "src", .value = src_with_params });
    try attrs.append(.{ .name = "alt", .value = props.alt });
    
    if (props.width) |w| {
        try attrs.append(.{ .name = "width", .value = try std.fmt.allocPrint(allocator, "{d}", .{w}) });
    }
    
    if (props.height) |h| {
        try attrs.append(.{ .name = "height", .value = try std.fmt.allocPrint(allocator, "{d}", .{h}) });
    }
    
    if (props.class) |cls| {
        try attrs.append(.{ .name = "class", .value = cls });
    }
    
    // 添加性能属性
    try attrs.append(.{ .name = "loading", .value = "lazy" });
    if (props.fetchpriority) |fp| {
        try attrs.append(.{ .name = "fetchpriority", .value = fp });
    }
    
    return _zx.zx(.img, .{
        .attributes = attrs.toOwnedSlice() catch unreachable,
    });
}

pub const OptimizedImageProps = struct {
    src: []const u8,
    alt: []const u8,
    width: ?u32 = null,
    height: ?u32 = null,
    class: ?[]const u8 = null,
    quality: u8 = 80,  // 1-100, 默认 80
    fetchpriority: ?[]const u8 = null,  // "high", "low", "auto"
};

const zx = @import("zx");
const std = @import("std");