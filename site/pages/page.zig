pub fn Page(allocator: zx.Allocator, _: ?[]const zx.Param, _: ?[]const u8) zx.Component {
    return (
        <main class="home-page flex flex-col items-center justify-center min-h-screen px-4">
            <img class="profile-image w-70 h-70 rounded-full object-cover mb-8" alt="Nurul Huda (Apon)" width="280" fetchpriority="high" src="https://nurulhudaapon.com/nurulhudaapon.webp" />
            <h1 class="name-title text-4xl md:text-5xl font-bold text-center mb-4 text-gray-900">Nurul Huda (Apon)</h1>
            <p class="job-title text-xl text-center mb-4 text-blue-600"><strong class="font-semibold">Staff Engineer</strong> at <strong class="font-semibold">Voyage Mobile Inc.</strong></p>
            <p class="bio text-center max-w-md mb-8 text-gray-600">A tech enthusiast, enrolling in Computer Science and Engineering at <strong class="font-semibold">Green University of Bangladesh</strong> and working as a <strong class="font-semibold">Staff Engineer</strong></p>
            <Navbar />
        </main>
    );
}

const zx = @import("zx");
const Navbar = @import("component.zig").Navbar;
const NavbarProps = @import("component.zig").NavbarProps;