const std = @import("std");
const zigx_nuhu_dev = @import("zigx_nuhu_dev");

const HASHNODE_GQL_URL = "https://gql.hashnode.com";
const HASHNODE_API_KEY = "YOUR_HASHNODE_API_KEY";

pub fn getPosts(allocator: std.mem.Allocator) !HashnodeResponse {
    var client = std.http.Client{ .allocator = allocator };
    const get_posts_query = @embedFile("queries/get_posts.gql");
    defer client.deinit();

    var aw = std.Io.Writer.Allocating.init(allocator);

    _ = try client.fetch(.{
        .method = .POST,
        .location = .{ .url = HASHNODE_GQL_URL },
        .headers = std.http.Client.Request.Headers{
            .authorization = .{ .override = HASHNODE_API_KEY },
            .content_type = .{ .override = "application/json" },
        },
        .payload = try std.json.Stringify.valueAlloc(allocator, .{
            .query = get_posts_query,
        }, .{}),

        .response_writer = &aw.writer,
    });

    const parsed = try std.json.parseFromSlice(HashnodeResponse, allocator, aw.written(), .{});
    const parsed_value: HashnodeResponse = parsed.value;

    return parsed_value;
}

pub const HashnodeResponse = struct {
    data: struct {
        publication: struct {
            isTeam: bool,
            title: []const u8,
            posts: struct {
                edges: []struct {
                    node: struct {
                        id: []const u8,
                        coverImage: ?struct {
                            url: []const u8,
                        },
                        publishedAt: []const u8,
                        readTimeInMinutes: u32,
                        slug: []const u8,
                        subtitle: ?[]const u8,
                        views: u32,
                        title: []const u8,
                        brief: []const u8,
                        url: []const u8,
                        author: struct {
                            name: []const u8,
                        },
                    },
                },
            },
        },
    },
};
