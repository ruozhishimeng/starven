---
name: remove-bg
description: 使用 rembg 去除图片背景并保存到指定位置。当用户提到"去背景"、"移除背景"、"抠图"时使用。
---

# Remove Background Skill

使用 `remove_bg.py` 脚本去除图片背景。

## 工作流程

1. 确认用户提供了：
   - 输入图片路径（`removebg/` 目录下的图片）
   - 输出目标（`ASSET/` 下的目标目录或文件路径）

2. 执行命令：
   ```bash
   python remove_bg.py <输入图片路径> <输出目录或文件路径>
   ```

3. 检查执行结果，告知用户

## 示例

- `python remove_bg.py removebg/stones.png Asset/Level` → 保存为 `Asset/Level/stones_nobg.png`
- `python remove_bg.py removebg/player.png Asset/character/player.png` → 保存为指定路径

## 注意事项

- 输出支持目录（自动创建，保持原文件名）或完整文件路径
- rembg 对人物、商品等主体效果较好，复杂背景可能需手动调整
