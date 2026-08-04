from PIL import Image

# 1. 이미지 로드 및 리사이즈 (FPGA BRAM 용량 한계 고려)
img = Image.open("b_king_1x_ns.png").convert("RGB")
img = img.resize((100, 100))  # 100x100 크기로 조정

with open("image_data.mem", "w") as f:
    for y in range(100):
        for x in range(100):
            r, g, b = img.getpixel((x, y))

            # # 8-bit RGB(0~255)를 4-bit(0~15)로 축소
            # r_4bit = r >> 4
            # g_4bit = g >> 4
            # b_4bit = b >> 4

            # # 12비트 16진수 문자열로 저장 (예: F00 = Red)
            # hex_val = f"{r_4bit:1X}{g_4bit:1X}{b_4bit:1X}"
            
            # f.write(f"{hex_val}\n")
            
            if (r == 0):
                f.write('0\n')
            else:
                f.write('1\n')

print("image_data.mem 생성 완료!")