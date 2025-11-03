const std = @import("std");
const zigx_nuhu_dev = @import("zigx_nuhu_dev");

const HASHNODE_GQL_URL = "https://gql.hashnode.com";
const HASHNODE_API_KEY = "YOUR_HASHNODE_API_KEY";

var cached_posts: ?[]Post = null;
var cached_at_ms: i64 = 0;

pub fn getPosts(allocator: std.mem.Allocator) ![]Post {
    const now_ms: i64 = std.time.milliTimestamp();
    const one_hour_ms: i64 = 3_600_000;

    // Return cached posts if they're still fresh (less than 1 hour old)
    if (cached_posts) |p| {
        if (now_ms - cached_at_ms < one_hour_ms) {
            return p;
        }
    }

    // Fetch fresh posts from Hashnode API
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

    const post_edges = parsed_value.data.publication.posts.edges;
    const pn = allocator.alloc(Post, post_edges.len) catch unreachable;

    const posts = blk: {
        for (pn, 0..) |*post_node, i| {
            const post = post_edges[i].node;
            post_node.* = .{
                .title = post.title,
                .brief = post.brief,
                .url = post.url,
            };
        }
        break :blk pn;
    };

    // Cache the posts
    cached_posts = posts;
    cached_at_ms = now_ms;

    return posts;
}

pub const Post = struct {
    title: []const u8,
    brief: []const u8,
    url: []const u8,
};

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
