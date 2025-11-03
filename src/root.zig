const std = @import("std");
const zigx_nuhu_dev = @import("zigx_nuhu_dev");

const HASHNODE_GQL_URL = "https://gql.hashnode.com";
const HASHNODE_API_KEY = "YOUR_HASHNODE_API_KEY";
const CACHE_DIR = ".cache";

pub fn getPosts(allocator: std.mem.Allocator) ![]Post {
    const now_ms: i64 = std.time.milliTimestamp();
    const one_hour_ms: i64 = 3_600_000;
    const cache_key = "hashnode_posts";

    // Try to read from cache
    if (readCache(allocator, cache_key, now_ms, one_hour_ms)) |cached_data| {
        // defer allocator.free(cached_data);
        return try parsePostsFromJson(allocator, cached_data);
    } else |_| {
        // Cache doesn't exist or is expired, continue to fetch fresh data
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

    const response_text = aw.written();

    // Cache the raw response
    writeCache(allocator, cache_key, response_text, now_ms) catch |err| {
        std.debug.print("Failed to write cache: {}\n", .{err});
    };

    return try parsePostsFromJson(allocator, response_text);
}

fn parsePostsFromJson(allocator: std.mem.Allocator, json_text: []const u8) ![]Post {
    const parsed = try std.json.parseFromSlice(HashnodeResponse, allocator, json_text, .{});
    // defer parsed.deinit();

    const parsed_value: HashnodeResponse = parsed.value;
    const post_edges = parsed_value.data.publication.posts.edges;
    const posts = try allocator.alloc(Post, post_edges.len);

    for (posts, 0..) |*post_node, i| {
        const post = post_edges[i].node;
        post_node.* = .{
            .title = post.title,
            .brief = post.brief,
            .url = post.url,
        };
    }

    return posts;
}

/// Generic cache read function
/// Reads cached data if it exists and is still valid based on TTL
/// Returns the raw cached data
fn readCache(allocator: std.mem.Allocator, key: []const u8, now_ms: i64, ttl_ms: i64) ![]const u8 {
    // Ensure cache directory exists
    var cache_dir = std.fs.cwd().openDir(CACHE_DIR, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) return error.CacheNotFound;
        return err;
    };
    defer cache_dir.close();

    // Iterate through cache directory to find matching key
    var iter = cache_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;

        // Check if filename starts with our key
        if (!std.mem.startsWith(u8, entry.name, key)) continue;

        // Extract timestamp from filename: key_timestamp.ext
        const underscore_idx = std.mem.lastIndexOf(u8, entry.name, "_") orelse continue;
        const dot_idx = std.mem.lastIndexOf(u8, entry.name, ".") orelse continue;

        if (underscore_idx >= dot_idx) continue;

        const timestamp_str = entry.name[underscore_idx + 1 .. dot_idx];
        const cached_at_ms = std.fmt.parseInt(i64, timestamp_str, 10) catch continue;

        // Check if cache is still valid
        if (now_ms - cached_at_ms < ttl_ms) {
            // Read and return the raw file content
            const file = try cache_dir.openFile(entry.name, .{});
            defer file.close();

            return try file.readToEndAlloc(allocator, 10 * 1024 * 1024); // 10MB max
        } else {
            // Cache is expired, delete it
            cache_dir.deleteFile(entry.name) catch {};
        }
    }

    return error.CacheNotFound;
}

/// Generic cache write function
/// Stores raw data in a file named with the key and timestamp
fn writeCache(allocator: std.mem.Allocator, key: []const u8, value: []const u8, timestamp_ms: i64) !void {
    // Ensure cache directory exists
    std.fs.cwd().makeDir(CACHE_DIR) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    // Clean up old cache files for this key
    var cache_dir = try std.fs.cwd().openDir(CACHE_DIR, .{ .iterate = true });
    defer cache_dir.close();

    var iter = cache_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (std.mem.startsWith(u8, entry.name, key)) {
            cache_dir.deleteFile(entry.name) catch {};
        }
    }

    // Create new cache file with timestamp in filename
    const cache_filename = try std.fmt.allocPrint(allocator, "{s}/{s}_{d}.txt", .{ CACHE_DIR, key, timestamp_ms });
    defer allocator.free(cache_filename);

    const file = try std.fs.cwd().createFile(cache_filename, .{});
    defer file.close();

    try file.writeAll(value);
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
