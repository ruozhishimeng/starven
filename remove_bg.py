"""
使用 rembg 库去除图片背景（优化边缘）

用法:
    python remove_bg.py <输入图片路径> <输出目录>
    python remove_bg.py <输入图片路径> <输出文件路径>

示例:
    python remove_bg.py removebg/stones.png Asset/Level
    python remove_bg.py removebg/player.png Asset/character/player.png
"""

from rembg import remove
from PIL import Image
import sys
import os

def remove_background(input_path, output_path, alpha_matting=True):
    """
    去除图片背景

    Args:
        input_path: 输入图片路径 (支持 PNG/JPG)
        output_path: 输出目录 或 输出文件路径
        alpha_matting: 是否启用边缘优化（消除渐变残留）
    """
    if not os.path.exists(input_path):
        print(f"错误: 文件不存在 - {input_path}")
        return False

    # 判断 output_path 是目录还是文件
    if output_path.endswith(os.sep) or not os.path.splitext(output_path)[1]:
        # 是目录：自动创建 + 保持原文件名
        output_dir = output_path.rstrip(os.sep)
        if not output_dir:
            print(f"错误: 输出目录不能为空")
            return False
        os.makedirs(output_dir, exist_ok=True)
        filename = os.path.basename(input_path)
        name, _ = os.path.splitext(filename)
        output_file = os.path.join(output_dir, f"{name}.png")
    else:
        # 是文件路径：自动创建父目录
        output_file = output_path
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

    print(f"正在处理: {input_path}")

    try:
        input_image = Image.open(input_path)
        output_image = remove(
            input_image,
            alpha_matting=alpha_matting,
            alpha_matting_foreground_threshold=250,
            alpha_matting_background_threshold=20
        )
        output_image.save(output_file, "PNG")
        print(f"完成! 保存为: {output_file}")
        return True
    except Exception as e:
        print(f"错误: 处理失败 - {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("用法: python remove_bg.py <输入图片路径> <输出目录>")
        print("       python remove_bg.py <输入图片路径> <输出文件路径>")
        print("")
        print("示例:")
        print("  python remove_bg.py removebg/stones.png Asset/Level")
        print("  python remove_bg.py removebg/player.png Asset/character/player.png")
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2]
        remove_background(input_path, output_path)
