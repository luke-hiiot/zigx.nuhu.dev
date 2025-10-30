const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zigx_nuhu_dev", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    setupZigx(b, .{
        .target = target,
        .optimize = optimize,
    }, mod);

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

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}

fn setupZigx(b: *std.Build, module_opts: std.Build.Module.CreateOptions, root_module: *std.Build.Module) void {
    const exe = b.addExecutable(.{
        .name = "www_zigx_nuhu_dev",
        .root_module = b.createModule(.{
            .root_source_file = b.path("site/main.zig"),
            .target = module_opts.target,
            .optimize = module_opts.optimize,
            .imports = &.{
                .{ .name = "zigx_nuhu_dev", .module = root_module },
            },
        }),
    });

    const httpz = b.dependency("httpz", .{
        .target = module_opts.target,
        .optimize = module_opts.optimize,
    });
    exe.root_module.addImport("httpz", httpz.module("httpz"));

    const zigx = b.dependency("zigx_prototype", .{
        .target = module_opts.target,
        .optimize = module_opts.optimize,
    });
    exe.root_module.addImport("zx", zigx.module("zx"));

    b.installArtifact(exe);
    const run_step = b.step("serve", "Run the ZigX website");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
}
