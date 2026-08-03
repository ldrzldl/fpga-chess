`timescale 1ps/1ps

module top (
    input wire reset,
    input wire clk
);
    reg [24:0] opponent_board;
    reg [24:0] team_board;
    reg [24:0] king_board;
    reg [24:0] rook_board;
    reg [24:0] pawn_board;
    reg [24:0] sel_piece_board;
    reg [24:0] move_board;
    move_generator mg(opponent_board, team_board, king_board, rook_board, pawn_board, sel_piece_board, move_board);

endmodule