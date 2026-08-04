`timescale 1ns/1ps

module tb_vga_image_top;

    // 입력 신호 (reg)
    reg clk_25MHz;
    reg reset;

    // 출력 신호 (wire)
    wire hsync;
    wire vsync;
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    // UUT (Unit Under Test) 인스턴스화
    vga_image_top uut (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // 25MHz 클럭 생성 (주기 40ns -> 20ns 마다 반전)
    always #20 clk_25MHz = ~clk_25MHz;

    integer file;
    integer x, y;

    initial begin
        // 초기화
        clk_25MHz = 0;
        reset = 1;
        #100;
        reset = 0;

        $display("=== VGA 시뮬레이션 시작 ===");

        // PPM 이미지 파일 생성 (ASCII PPM / P3 포맷)
        file = $fopen("vga_result.ppm", "w");
        if (file == 0) begin
            $display("ERROR: 파일을 생성할 수 없습니다.");
            $finish;
        end

        // PPM 헤더 작성: P3, 640x480 해상도, 최대 색상값 255
        $fwrite(file, "P3\n640 480\n255\n");

        // VSYNC의 첫 번째 하강 엣지(새 프레임 시작)까지 대기
        @(negedge vsync);
        // VSYNC 상승 엣지(Back Porch 시작)까지 대기
        @(posedge vsync);

        // VSYNC Back Porch (33 라인) 대기
        repeat(33 * 800) @(posedge clk_25MHz);

        // Active Video 영역 (480 라인) 캡처
        for (y = 0; y < 480; y = y + 1) begin
            // HSYNC Back Porch (48 픽셀) 대기
            repeat(48) @(posedge clk_25MHz);

            // Active 픽셀 영역 (640 픽셀) 파일에 기록
            for (x = 0; x < 640; x = x + 1) begin
                // 4-bit RGB (0~15)를 8-bit RGB (0~255) 레벨로 확장하여 저장
                $fwrite(file, "%d %d %d ", {red, 4'b0000}, {green, 4'b0000}, {blue, 4'b0000});
                @(posedge clk_25MHz);
            end

            // HSYNC Front Porch (16) + HSYNC Sync Pulse (96) = 112 픽셀 대기
            repeat(112) @(posedge clk_25MHz);
        end

        $fclose(file);
        $display("=== 시뮬레이션 완료: 'vga_result.ppm' 저장 완료 ===");
        $finish;
    end

endmodule