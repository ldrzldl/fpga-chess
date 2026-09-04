`timescale 1ns/1ps

module tb_vga_top;

    // 입력 신호 (reg)
    reg clk_25MHz;
    reg reset;

    // 출력 신호 (wire)
    wire hsync;
    wire vsync;
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    // 백(하단) 선공 기준
    reg is_turn_white  = 1'b1;

    // 기물 종류별 보드 (가로·세로 대칭 구조)
    // 각 5비트 묶음: [Row 4(하단) _ Row 3 _ Row 2(중앙 빈칸) _ Row 1 _ Row 0(상단)]
    reg [0:24] king_board     = 25'b00100_00000_00000_00000_00100;
    reg [0:24] rook_board     = 25'b10001_00000_00000_00000_10001;
    reg [0:24] pawn_board     = 25'b00000_11011_00100_11111_00000;

    // 백 기물 (하단 Row 3, Row 4) -> 턴 주체(team_board)
    reg [0:24] team_board     = 25'b10101_11011_00100_00000_00000;

    // 흑 기물 (상단 Row 0, Row 1) -> 상대방(opponent_board)
    reg [0:24] opponent_board = 25'b00000_00000_00000_11111_10101;


    // UUT (Unit Under Test) 인스턴스화
    vga_top uut (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .is_turn_white(is_turn_white),
        .team_board(team_board),
        .opponent_board(opponent_board),
        .king_board(king_board),
        .rook_board(rook_board),
        .pawn_board(pawn_board),
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
            // Active 픽셀 영역 (640 픽셀) 파일에 기록
            for (x = 0; x < 640; x = x + 1) begin
                // 4-bit RGB (0~15)를 8-bit RGB (0~255) 레벨로 확장하여 저장
                $fwrite(file, "%d %d %d ", {red, 4'b0000}, {green, 4'b0000}, {blue, 4'b0000});
                @(posedge clk_25MHz);
            end

            // HSYNC Back Porch (48) + HSYNC Front Porch (16) + HSYNC Sync Pulse (96) = 112 픽셀 대기
            repeat(160) @(posedge clk_25MHz);
        end

        $fclose(file);
        $display("=== 시뮬레이션 완료: 'vga_result.ppm' 저장 완료 ===");
        $finish;
    end

endmodule