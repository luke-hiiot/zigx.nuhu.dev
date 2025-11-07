pub const NavbarProps = struct {
};

pub fn Navbar(allocator: zx.Allocator, props: NavbarProps) zx.Component {
    _ = props;
    return (
        <nav class="nav-buttons flex flex-wrap justify-center gap-4 my-8">
            <a class="nav-button px-6 py-3 bg-gray-100 rounded-lg text-gray-800 font-medium hover:bg-gray-200 transition-colors" href="/">Home</a>
            <a class="nav-button px-6 py-3 bg-gray-100 rounded-lg text-gray-800 font-medium hover:bg-gray-200 transition-colors" href="/blog">Blog</a>
            <a class="nav-button px-6 py-3 bg-gray-100 rounded-lg text-gray-800 font-medium hover:bg-gray-200 transition-colors" href="/about">About</a>
            <a class="nav-button nav-button-external px-6 py-3 bg-gray-100 rounded-lg text-gray-800 font-medium hover:bg-gray-200 transition-colors flex items-center gap-1" href="https://nuhu.dev" target="_blank" rel="noopener noreferrer">Dev ↗</a>
        </nav>
    );
}

const zx = @import("zx");