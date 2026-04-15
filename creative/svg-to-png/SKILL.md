---
name: svg-to-png
description: Converts SVG files into PNG reliably with a tool-first workflow and fallbacks. Use this skill when the user wants to export SVG as PNG, batch convert icons or diagrams, render transparent PNGs from SVG, prepare social images, generate raster previews, or needs a reproducible command/script for SVG to PNG conversion. Trigger on requests like svg转png, 导出png, convert svg to png, batch render SVGs, or export vector graphics to bitmap.
---

# SVG To PNG

把 SVG 转成 PNG，不要先争论工具，先解决三个实际问题：

1. 要单张还是批量
2. 要保真还是只要一个可用预览
3. 目标尺寸和透明背景要求是什么

## Step 1：先明确转换要求

至少确认：

- 输入文件路径
- 输出路径或输出目录
- 目标宽高，或缩放倍数
- 是否保留透明背景
- 是单张还是批量

如果用户没说尺寸，默认按 SVG 原始 viewBox 比例导出。

## Step 2：优先走可执行路径

优先级：

1. 直接用脚本 `scripts/convert-svg-to-png.sh`
2. 若脚本不适用，再读取 `references/conversion-methods.md`

脚本会自动尝试这些工具：

- `qlmanage`（macOS Quick Look）
- `rsvg-convert`
- `inkscape`
- `magick`

原则：

- 优先自动探测，不要让用户先猜环境
- 能命令行稳定完成，就不要退回手工截图
- 只有在本机工具都缺失时，才建议浏览器截图或设计工具导出

## Step 3：默认命令形式

单文件：

```bash
./scripts/convert-svg-to-png.sh input.svg output.png
```

指定宽度：

```bash
./scripts/convert-svg-to-png.sh input.svg output.png 1600
```

批量时，优先循环调用脚本，而不是每次重写整段命令。

## Step 4：质量检查

- 文字是否被裁切
- 透明背景是否保留
- 线条在 1x 和 2x 下是否发虚
- 输出尺寸是否符合投放平台要求

如果 PNG 用于封面或社媒图，通常至少导出到 1200px 宽，避免模糊。

## 什么时候读参考文件

- 需要理解不同工具差异 -> 读取 `references/conversion-methods.md`
- 需要批量转换策略 -> 仍优先看脚本，再按参考文件扩展

## 注意事项

- 不要默认截图，截图是最后降级方案
- 不要忽略字体和裁切问题
- 如果 SVG 依赖外链资源，先提醒用户嵌入资源后再转
- 如果用户只是要“发得出去”，优先给最短可执行路径

## Keywords

svg转png, SVG 转 PNG, export png, rasterize svg, render svg, batch convert svg, thumbnail, transparent png, qlmanage, inkscape, rsvg-convert, ImageMagick
