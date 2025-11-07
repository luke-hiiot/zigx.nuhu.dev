# ZX 框架

ZX 是一个基于 Zig 语言的 Web 框架，类似于 Next.js，提供了 JSX 风格的语法用于构建现代 Web 应用。使用 `.zx` 文件扩展名表示 JSX 风格的组件。

## 主要特性

### 1. JSX 风格语法
- 使用 `.zx` 文件扩展名
- 支持 JSX 类似的标签语法
- 支持动态表达式 `{expression}`、条件渲染、循环等

### 2. 文件系统路由
- 基于文件系统的路由系统
- 支持动态路由参数（如 `[id].zx`）
- 支持嵌套路由

### 3. 服务端渲染 (SSR)
- 在服务器端生成 HTML
- 快速响应时间
- SEO 友好

### 4. 热模块替换 (HMR)
- 开发时热更新功能
- 实时查看代码更改效果
- 提高开发效率

### 5. 类型安全
- 利用 Zig 的强类型系统
- 编译时类型检查
- 减少运行时错误

## 运行项目

```bash
zig build serve
```

## 项目结构

```
.
├── build.zig          # Zig 构建配置文件
├── build.zig.zon      # Zig 依赖配置文件
├── site/
│   ├── main.zig       # 应用入口点
│   ├── meta.zig       # 路由配置
│   ├── pages/         # 页面组件
│   │   ├── page.zx    # 首页 (会转译为 page.zig)
│   │   ├── layout.zx  # 布局组件 (会转译为 layout.zig)
│   │   ├── about/
│   │   │   └── page.zx
│   │   └── user/
│   │       └── [id].zx # 动态路由
│   └── assets/        # 静态资源
├── zx/                # ZX 框架源码
│   ├── src/
│   │   └── app.zig    # 核心框架实现
│   └── tools/         # 工具脚本
├── http.zig/          # HTTP 服务器实现
└── tools/
    └── transpile_zx_to_zig.sh  # .zx 文件转译脚本
```

## 转译过程

ZX 框架使用 `.zx` 文件扩展名来编写 JSX 风格的组件。在构建过程中，这些文件需要被转译为标准的 Zig 文件：

1. **标记组件**：使用 `.zx` 扩展名编写组件
2. **转译过程**：运行转译脚本将 `.zx` 文件转换为 `.zig` 文件
3. **编译构建**：Zig 编译器编译已转译的 `.zig` 文件

### 转译脚本
```bash
./tools/transpile_zx_to_zig.sh
```

该脚本会查找所有 `.zx` 文件并将其转换为 `.zig` 文件，同时正确处理导入语句。

## 组件系统

ZX 提供了强大的组件系统，支持：

### 基础组件
```zig
// component.zx
pub fn Navbar(allocator: zx.Allocator, props: NavbarProps) zx.Component {
    _ = props;
    return (
        <nav class="nav">
            <a href="/">首页</a>
            <a href="/about">关于</a>
        </nav>
    );
}
```

### 动态内容
- 支持 `{expression}` 语法插入动态内容
- 支持条件渲染：`{if (condition) (<div>True</div>) else (<div>False</div>)}`
- 支持循环渲染：`{for (items) |item| (<li>{item}</li>)}`
- 支持格式化表达式：`{[count:d]}`

## 路由系统

ZX 框架提供基于文件系统的路由：

### 静态路由
- `pages/page.zx` → `/`
- `pages/about/page.zx` → `/about`

### 动态路由
- `pages/user/[id].zx` → `/user/123` (参数通过 `params` 访问)

### 嵌套路由
通过在路由配置中嵌套定义实现

## 构建和运行

### 开发模式
```bash
# 转译 .zx 文件
./tools/transpile_zx_to_zig.sh

# 构建并运行开发服务器
zig build run
```

### 生产构建
```bash
# 转译 .zx 文件
./tools/transpile_zx_to_zig.sh

# 生产构建
zig build -Doptimize=ReleaseFast
```

### 图像优化

ZX 框架支持图像优化功能，包括:

- 响应式图像生成
- 不同格式转换 (JPEG, PNG, WebP 等)
- 质量控制
- 尺寸调整

#### 使用构建系统进行图像优化
```bash
# 优化项目中的所有图像
zig build optimize-images

# 或者在构建时自动处理图像
zig build assets
```

图像优化工具会自动:
1. 扫描 `site/assets/images/` 目录中的图像文件
2. 创建优化版本并保存到 `site/assets/images/optimized/`
3. 生成适合不同屏幕尺寸的响应式版本

#### 优化的图像组件
ZX 提供了优化的图像组件，支持懒加载和优先级获取:

```zx
// 在 .zx 文件中使用优化的图像组件
const OptimizedImage = @import("image_component.zig").OptimizedImage;
const OptimizedImageProps = @import("image_component.zig").OptimizedImageProps;

// 使用示例
pub fn Page(allocator: zx.Allocator, params: ?[]const zx.Param, data: ?[]const u8) zx.Component {
    return (
        <div>
            <OptimizedImage 
                src="/images/example.jpg" 
                alt="示例图像" 
                width=800 
                height=600 
                class="responsive-image"
                quality=85
                fetchpriority="high"
            />
        </div>
    );
}
```

## 已实现功能

- ✅ 路由系统 (文件系统路由、动态路由、嵌套路由)
- ✅ 服务端渲染 (SSR)
- ✅ 热模块替换 (HMR)
- ✅ 组件系统 (JSX 风格语法)
- ✅ 类型安全
- ✅ 内置开发服务器

## 与 Next.js 的比较

| 特性 | Next.js | ZX |
|------|---------|-----|
| 语言 | JavaScript/TypeScript | Zig |
| 性能 | 良好 | 更高 (编译为原生代码) |
| 部署 | 需 Node.js 环境 | 单个二进制文件 |
| 生态系统 | 成熟 | 新兴但快速发展 |
| 类型安全 | TypeScript | 编译时强类型 |