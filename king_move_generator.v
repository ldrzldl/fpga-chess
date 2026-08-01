`timescale 1ps/1ps

module king_move_map (
    input  wire [63:0] grid_in,
    input wire [63:0] team_piece,
    output wire [63:0] grid_out
);

    // 가장자리 랩어라운드 방지용 마스크
    localparam [63:0] MASK_NOT_LEFT  = 64'hFEFE_FEFE_FEFE_FEFE;
    localparam [63:0] MASK_NOT_RIGHT = 64'h7F7F_7F7F_7F7F_7F7F;

    wire [63:0] shift_l, shift_r, shift_u, shift_d;
    wire [63:0] shift_ul, shift_ur, shift_dl, shift_dr;
    wire [63:0] neighbors;

    // 1. 십자 방향 (상, 하, 좌, 우)
    assign shift_l = (grid_in & MASK_NOT_LEFT)  >> 1;
    assign shift_r = (grid_in & MASK_NOT_RIGHT) << 1;
    assign shift_u = grid_in >> 8;
    assign shift_d = grid_in << 8;

    // 2. 대각선 방향 (상좌, 상우, 하좌, 하우)
    assign shift_ul = (grid_in & MASK_NOT_LEFT)  >> 9;
    assign shift_ur = (grid_in & MASK_NOT_RIGHT) >> 7;
    assign shift_dl = (grid_in & MASK_NOT_LEFT)  << 7;
    assign shift_dr = (grid_in & MASK_NOT_RIGHT) << 9;

    // 3. 8방향 결과를 모두 합침
    assign neighbors = shift_l | shift_r | shift_u | shift_d |
                       shift_ul | shift_ur | shift_dl | shift_dr;

    // 4. 원위치(자기 자신)에 있던 1을 제외
    assign grid_out = neighbors & ~grid_in & ~team_piece;

endmodule