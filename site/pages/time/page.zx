pub fn Page(allocator: zx.Allocator, _: ?[]const zx.Param, _: ?[]const u8) zx.Component {
    const time = std.time.timestamp();

    return (
        <div>
            <h1>Time:</h1> 
            <p>
                {[time:d]}
            </p>
        </div>
    );
}

const zx = @import("zx");
const std = @import("std");