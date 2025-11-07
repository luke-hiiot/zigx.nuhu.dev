pub fn Page(allocator: zx.Allocator, params: ?[]const zx.Param, data: ?[]const u8) zx.Component {
    const user_id = if (params) |p| blk: {
        for (p) |param| {
            if (std.mem.eql(u8, param.name, "id")) {
                break :blk param.value;
            }
        }
        break :blk "unknown";
    } else "unknown";
    
    // 使用_fmt来格式化用户ID
    const user_id_text = std.fmt.allocPrint(allocator, "User ID: {s}", .{user_id}) catch "User ID: unknown";
    
    var data_text: []const u8 = "";
    if (data) |d| {
        data_text = std.fmt.allocPrint(allocator, "Data: {s}", .{d}) catch "";
    }
    
    return (
        <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <span> welcome china</span>
            <div class="max-w-3xl mx-auto bg-white rounded-lg shadow-md p-8">
                <div class="text-center mb-8">
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">User Profile</h1>
                    <div class="w-20 h-20 bg-blue-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span class="text-white text-xl font-bold">{user_id[0..1]}</span>
                    </div>
                </div>
                <div class="space-y-4">
                    <div class="bg-gray-100 rounded-lg p-4">
                        <p class="text-lg font-medium text-gray-800">{user_id_text}</p>
                    </div>
                    {if (data_text.len > 0) (
                        <div class="bg-gray-100 rounded-lg p-4">
                            <p class="text-gray-700">{data_text}</p>
                        </div>
                    ) else ""}
                </div>
                <div class="mt-8 flex justify-center space-x-4">
                    <a href="/" class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors">返回首页</a>
                    <a href="/users" class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400 transition-colors">所有用户</a>
                </div>
            </div>
        </div>
    );
}

const zx = @import("zx");
const std = @import("std");