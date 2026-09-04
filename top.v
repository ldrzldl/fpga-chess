module top (
    input  wire        clk_100MHz,     // 보드 기본 오실레이터
    input  wire        btn_reset,
    input  wire        btn_u, btn_d, btn_l, btn_r, btn_s,
    // VGA 핀 (R-2R DAC 12비트 RGB444)
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);

    // 1. 25MHz 클럭 생성 (100MHz -> 25MHz: 4분주)
    reg [1:0] clk_div = 2'b0;
    always @(posedge clk_100MHz) begin
        clk_div <= clk_div + 1'b1;
    end
    wire clk_25MHz = clk_div[1]; // FPGA 프리미티브 PLL/MMCM을 쓰면 지터가 더 적어 권장됨

    // 2. 버튼 디바운스 및 1클럭 펄스 신호 (25MHz 동기화)
    wire up, down, left, right, sel;
    debounce_edge db_u (.clk(clk_25MHz), .reset(btn_reset), .btn_in(btn_u), .btn_pulse(up));
    debounce_edge db_d (.clk(clk_25MHz), .reset(btn_reset), .btn_in(btn_d), .btn_pulse(down));
    debounce_edge db_l (.clk(clk_25MHz), .reset(btn_reset), .btn_in(btn_l), .btn_pulse(left));
    debounce_edge db_r (.clk(clk_25MHz), .reset(btn_reset), .btn_in(btn_r), .btn_pulse(right));
    debounce_edge db_s (.clk(clk_25MHz), .reset(btn_reset), .btn_in(btn_s), .btn_pulse(sel));

    // 3. 체스 코어와 VGA를 연결할 내부 버스
    wire [24:0] team_board;
    wire [24:0] opponent_board;
    wire [24:0] king_board;
    wire [24:0] rook_board;
    wire [24:0] pawn_board;
    wire        is_turn_white;

    // 4. 게임 로직 인스턴스
    chess_core u_core (
        .clk      (clk_25MHz),
        .reset          (btn_reset),
        .up             (up),
        .down           (down),
        .left           (left),
        .right          (right),
        .sel            (sel),
        .is_turn_white  (is_turn_white),
        .team_board     (team_board),
        .opponent_board (opponent_board),
        .king_board     (king_board),
        .rook_board     (rook_board),
        .pawn_board     (pawn_board)
    );

    // 5. VGA 컨트롤러 인스턴스
    vga_top u_vga (
        .clk      (clk_25MHz),
        .reset          (btn_reset),
        .is_turn_white  (is_turn_white),
        .team_board     (team_board),
        .opponent_board (opponent_board),
        .king_board     (king_board),
        .rook_board     (rook_board),
        .pawn_board     (pawn_board),
        .hsync          (vga_hsync),
        .vsync          (vga_vsync),
        .red            (vga_r),
        .green          (vga_g),
        .blue           (vga_b)
    );

endmodule
