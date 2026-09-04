module vga_top (
    input wire clk,
    input wire reset,
    input wire is_turn_white,
    input wire [24:0] team_board,
    input wire [24:0] opponent_board,
    input wire [24:0] king_board,
    input wire [24:0] rook_board,
    input wire [24:0] pawn_board,
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

    // localparam WHITE_BG_COLOR = 12'h00F;
    // localparam BLACK_BG_COLOR = 12'h0F0;

    wire [9:0] px_x, px_y;
    wire video_on;

    wire [4:0] square_index; // 24~0(보드 인덱스)
    wire is_square_white;
    wire [13:0] local_px_index;
    wire board_on; // 보드를 그리고 있는지
    
    // 모듈 인스턴스화
    vga_controller vc (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .px_x(px_x),
        .px_y(px_y),
        .video_on(video_on)
    );

    square_info_generator sig (
        .px_x(px_x),
        .px_y(px_y),
        .square_index(square_index),
        .is_square_white(is_square_white),
        .local_px_index(local_px_index),
        .board_on(board_on)
    );

    color_generator cg (
        .is_turn_white(is_turn_white),
        .team_board(team_board),
        .opponent_board(opponent_board),
        .king_board(king_board),
        .rook_board(rook_board),
        .pawn_board(pawn_board),
        .square_index(square_index),
        .is_square_white(is_square_white),
        .local_px_index(local_px_index),
        .board_on(board_on),
        .red(red),
        .green(green),
        .blue(blue)
    );

endmodule