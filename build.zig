const std = @import("std");
const zx = @import("zx");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zigx_nuhu_dev", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    // const zx_dep = b.dependency("zx", .{ .target = target, .optimize = optimize });
    zx.setup(b, .{
        .name = "zx_site",
        .root_module = b.createModule(.{
            .root_source_file = b.path("site/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = mod },
                // .{ .name = "zx", .module = zigx_dep.module("zx") },
            },
        }),
    });

    const exe = b.addExecutable(.{
        .name = "zigx_nuhu_dev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    // Add image optimization step
    const optimize_images_step = b.step("optimize-images", "Optimize images in the project");
    
    // Create a custom build step for image optimization
    const optimize_images_cmd = b.addSystemCommand(&[_][]const u8{
        "zig", "run", "tools/optimize_images.zig",
    });
    optimize_images_step.dependOn(&optimize_images_cmd.step);

    // Run image optimization before the main build
    const assets_step = b.step("assets", "Process assets including images");
    assets_step.dependOn(optimize_images_step);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(assets_step);

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}