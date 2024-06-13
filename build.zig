const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = .ReleaseFast;

    const exe = b.addExecutable(.{
        .name = "webserver",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const StaticHttpFileServer = b.dependency("StaticHttpFileServer", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("StaticHttpFileServer", StaticHttpFileServer.module("StaticHttpFileServer"));

    b.installArtifact(exe);
}
