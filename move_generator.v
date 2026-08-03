`timescale 1ps/1ps

module move_generator (
    input wire [24:0] opponent_board,
    input wire [24:0] team_board,
    input wire [24:0] king_board,
    input wire [24:0] rook_board,
    input wire [24:0] pawn_board,
    input wire [24:0] sel_piece_board,
    output wire [24:0] move_board
);

    wire [24:0] king_move_board;
    king_move_generator kmg(sel_piece_board, king_board, team_board, king_move_board);
    wire [24:0] rook_move_board;
    rook_move_generator rmg(sel_piece_board, rook_board, team_board, opponent_board, rook_move_board);
    wire [24:0] pawn_move_board;
    pawn_move_generator pmg(sel_piece_board, pawn_board, team_board, opponent_board, pawn_move_board);

    assign move_board = king_move_board | rook_move_board | pawn_move_board;

endmodule