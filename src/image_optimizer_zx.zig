const std = @import("std");
const image_optimizer = @import("image_optimizer.zig");

// This module provides image optimization functionality for ZX framework
pub const ImageOptimization = struct {
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator) ImageOptimization {
        return .{
            .allocator = allocator,
        };
    }
    
    // Generate an optimized image tag with responsive features
    pub fn generateImageTag(
        self: *ImageOptimization,
        src: []const u8,
        alt: []const u8,
        width: ?u32,
        height: ?u32,
        quality: u8,
        classes: ?[]const u8
    ) ![]const u8 {
        _ = self;
        
        var result = std.ArrayList(u8).init(self.allocator);
        defer result.deinit();
        
        // Determine if we need responsive variants (if no fixed dimensions provided)
        const needs_responsive = (width == null or height == null);
        
        if (needs_responsive) {
            // Generate responsive picture element
            try result.appendSlice("<picture>");
            
            // In a real implementation, we would generate different size variants
            // For now, we'll just include a source with a mock srcset
            
            // Add source element with mock srcset
            try result.appendSlice("<source ");
            try result.appendSlice("srcset=\"");
            try result.appendSlice(src);
            try result.appendSlice(" 1x, ");
            try result.appendSlice(std.fmt.comptimePrint("{s}?w={d} ", .{ src, (width orelse 800) * 2 }));
            try result.appendSlice("2x\" ");
            try result.appendSlice("type=\"image/webp\">");
            
            // Add fallback img element
            try result.appendSlice("<img ");
            if (classes) |cls| {
                try result.appendSlice("class=\"");
                try result.appendSlice(cls);
                try result.appendSlice("\" ");
            }
            try result.appendSlice("src=\"");
            try result.appendSlice(src);
            try result.appendSlice("\" alt=\"");
            try result.appendSlice(alt);
            try result.appendSlice("\" ");
            if (width) |w| {
                try result.appendSlice("width=\"");
                try result.appendSlice(try std.fmt.allocPrint(self.allocator, "{d}", .{w}));
                try result.appendSlice("\" ");
            }
            if (height) |h| {
                try result.appendSlice("height=\"");
                try result.appendSlice(try std.fmt.allocPrint(self.allocator, "{d}", .{h}));
                try result.appendSlice("\" ");
            }
            try result.appendSlice("loading=\"lazy\" fetchpriority=\"low\">");
            
            try result.appendSlice("</picture>");
        } else {
            // Generate regular img tag with optimized src
            try result.appendSlice("<img ");
            if (classes) |cls| {
                try result.appendSlice("class=\"");
                try result.appendSlice(cls);
                try result.appendSlice("\" ");
            }
            try result.appendSlice("src=\"");
            // In real implementation, we would add optimization parameters to the URL
            try result.appendSlice(src);
            if (quality != 80) { // Default quality
                // Add quality parameter if not default
                try result.appendSlice("?q=");
                try result.appendSlice(try std.fmt.allocPrint(self.allocator, "{d}", .{quality}));
            }
            try result.appendSlice("\" alt=\"");
            try result.appendSlice(alt);
            try result.appendSlice("\" ");
            if (width) |w| {
                try result.appendSlice("width=\"");
                try result.appendSlice(try std.fmt.allocPrint(self.allocator, "{d}", .{w}));
                try result.appendSlice("\" ");
            }
            if (height) |h| {
                try result.appendSlice("height=\"");
                try result.appendSlice(try std.fmt.allocPrint(self.allocator, "{d}", .{h}));
                try result.appendSlice("\" ");
            }
            try result.appendSlice("loading=\"lazy\" fetchpriority=\"low\">");
        }
        
        return result.toOwnedSlice();
    }
    
    // Process a directory of images for optimization
    pub fn processImageDirectory(self: *ImageOptimization, input_dir: []const u8, output_dir: []const u8) !void {
        _ = self;
        _ = input_dir;
        _ = output_dir;
        
        // In a real implementation, this would use the optimizer to process all images
        // For now, we'll just create a stub implementation
        std.debug.print("Processing images from {s} to {s}\n", .{ input_dir, output_dir });
    }
    
    // Create responsive image variants
    pub fn createResponsiveImage(self: *ImageOptimization, base_url: []const u8, alt: []const u8) ![]const u8 {
        _ = self;
        
        // This would create different sized versions of an image
        var result = std.ArrayList(u8).init(self.allocator);
        defer result.deinit();
        
        try result.appendSlice("<picture>");
        try result.appendSlice("<source ");
        try result.appendSlice("srcset=\"");
        // In real implementation, we would generate different sizes
        try result.appendSlice(base_url);
        try result.appendSlice("\" ");
        try result.appendSlice("type=\"image/webp\">");
        try result.appendSlice("<img ");
        try result.appendSlice("src=\"");
        try result.appendSlice(base_url);
        try result.appendSlice("\" ");
        try result.appendSlice("alt=\"");
        try result.appendSlice(alt);
        try result.appendSlice("\" ");
        try result.appendSlice("loading=\"lazy\">");
        try result.appendSlice("</picture>");
        
        return result.toOwnedSlice();
    }
};

// Helper function to create an optimized image component function for ZX
pub fn createImageComponent(allocator: std.mem.Allocator, props: ImageProps) ![]const u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();
    
    try result.appendSlice("pub fn OptimizedImage(allocator: zx.Allocator, props: ImageProps) zx.Component {\n");
    try result.appendSlice("    _ = allocator;\n");
    try result.appendSlice("    return (\n");
    try result.appendSlice("        <img ");
    
    // Add src attribute
    try result.appendSlice("src=\"");
    try result.appendSlice(props.src);
    try result.appendSlice("\" ");
    
    // Add alt attribute
    try result.appendSlice("alt=\"");
    try result.appendSlice(props.alt);
    try result.appendSlice("\" ");
    
    // Add width if provided
    if (props.width) |w| {
        try result.appendSlice("width=\"");
        try result.appendSlice(try std.fmt.allocPrint(allocator, "{d}", .{w}));
        try result.appendSlice("\" ");
    }
    
    // Add height if provided
    if (props.height) |h| {
        try result.appendSlice("height=\"");
        try result.appendSlice(try std.fmt.allocPrint(allocator, "{d}", .{h}));
        try result.appendSlice("\" ");
    }
    
    // Add loading attribute for optimization
    try result.appendSlice("loading=\"lazy\" ");
    
    // Add fetchpriority if high priority
    if (props.fetchpriority) |fp| {
        try result.appendSlice("fetchpriority=\"");
        try result.appendSlice(fp);
        try result.appendSlice("\" ");
    }
    
    // Add CSS classes
    if (props.class) |cls| {
        try result.appendSlice("class=\"");
        try result.appendSlice(cls);
        try result.appendSlice("\" ");
    }
    
    try result.appendSlice("/>\n    );\n}\n\n");
    try result.appendSlice("pub const ImageProps = struct {\n");
    try result.appendSlice("    src: []const u8,\n");
    try result.appendSlice("    alt: []const u8,\n");
    try result.appendSlice("    width: ?u32 = null,\n");
    try result.appendSlice("    height: ?u32 = null,\n"); 
    try result.appendSlice("    class: ?[]const u8 = null,\n");
    try result.appendSlice("    fetchpriority: ?[]const u8 = null,\n};\n");
    
    return result.toOwnedSlice();
}

// Image properties struct
pub const ImageProps = struct {
    src: []const u8,
    alt: []const u8,
    width: ?u32,
    height: ?u32,
    class: ?[]const u8,
    fetchpriority: ?[]const u8,
};