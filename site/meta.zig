pub const routes = [_]zx.App.Meta.Route{
    .{
        .path = "/",
        .page = @import("./.zigx/pages/page.zig").Page,
        .layout = @import("./.zigx/pages/layout.zig").Layout,
        .routes = &.{
            .{
                .path = "/about",
                .page = @import("./.zigx/pages/about/page.zig").Page,
            },
            .{
                .path = "/time",
                .page = @import("./.zigx/pages/time/page.zig").Page,
            },
            .{
                .path = "/blog",
                .page = @import("./.zigx/pages/blog/page.zig").Page,
            },
        },
    },
};

pub const meta = zx.App.Meta{
    .routes = &routes,
};

const zx = @import("zx");
