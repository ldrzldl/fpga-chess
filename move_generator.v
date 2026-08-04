`timescale 1ps/1ps

module move_generator (
    input wire        is_white,        // <-- 추가: 현재 턴이 백(White)이면 1, 흑(Black)이면 0
    input wire [24:0] opponent_board,
    input wire [24:0] team_board,
    input wire [24:0] king_board,
    input wire [24:0] rook_board,
    input wire [24:0] pawn_board,
    input wire [24:0] start_pos_board,
    output wire [24:0] move_board
);

    wire [24:0] king_move_board;
    king_move_generator kmg(start_pos_board & king_board, team_board, king_move_board);
    
    wire [24:0] rook_move_board;
    rook_move_generator rmg(start_pos_board & rook_board, team_board, opponent_board, rook_move_board);
    
    wire [24:0] pawn_move_board;
    // <-- 수정: pmg의 두 번째 인자로 is_white를 전달
    pawn_move_generator pmg(start_pos_board & pawn_board, is_white, team_board, opponent_board, pawn_move_board);

    assign move_board = king_move_board | rook_move_board | pawn_move_board;

endmodule