module vga_image_top (
    input wire clk_25MHz,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

    wire [9:0] pixel_x, pixel_y;
    wire video_on;

    // 이미지가 출력될 시작 위치 설정 (X: 100~199, Y: 100~199)
    localparam IMG_X = 100;
    localparam IMG_Y = 100;
    localparam IMG_W = 100;
    localparam IMG_H = 100;

    // ROM 주소 계산
    reg [13:0] rom_addr;
    wire is_white;

    // 이미지 출력 영역 내에 있는지 판단
    wire img_on = (pixel_x >= IMG_X) && (pixel_x < IMG_X + IMG_W) &&
                 (pixel_y >= IMG_Y) && (pixel_y < IMG_Y + IMG_H);

    // 현재 픽셀 좌표를 ROM 1차원 주소로 변환
    // Address = (y_offset * width) + x_offset
    always @(*) begin
        if (img_on)
            rom_addr = (pixel_y - IMG_Y) * IMG_W + (pixel_x - IMG_X);
        else
            rom_addr = 0;
    end

    // 모듈 인스턴스화
    vga_controller vga_ctrl_inst (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on)
    );

    image_rom rom_inst (
        .clk(clk_25MHz),
        .addr(rom_addr),
        .is_white(is_white)
    );

    // RGB 출력 조건
    always @(*) begin
        if (!video_on) begin
            // Blanking 구간은 반드시 검은색
            {red, green, blue} = 12'h000;
        end else if (img_on) begin
            // 이미지 영역: ROM에서 가져온 색상 출력
            red   = {4{is_white}};
            green = {4{is_white}};
            blue  = {4{is_white}};
        end else begin
            // 배경 영역: 파란색 배경 출력
            {red, green, blue} = 12'h00F;
        end
    end

endmodule