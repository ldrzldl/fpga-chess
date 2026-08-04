`timescale 1ps/1ps

module king_move_generator (
<<<<<<< HEAD
    input  wire [24:0] start_pos_board,
    input wire [24:0] team_board, // 같은 팀 비트보드들 or연산으로 합치면 만들 수 있음
    output wire [24:0] king_move_board;
=======
    input  wire [24:0] dep_pos_board,
    input  wire [24:0] team_board, // 같은 팀 비트보드들 or연산으로 합치면 만들 수 있음
    output wire [24:0] king_move_board
>>>>>>> 13745d405a7b64bccf07790260afdb57c33a3446
);

    // 가장자리 랩어라운드 방지용 마스크
    localparam [24:0] MASK_NOT_LEFT  = 25'b11110_11110_11110_11110_11110;
    localparam [24:0] MASK_NOT_RIGHT = 25'b01111_01111_01111_01111_01111; 

    wire [24:0] shift_l, shift_r, shift_u, shift_d;
    wire [24:0] shift_ul, shift_ur, shift_dl, shift_dr;
    wire [24:0] neighbors;

    // 1. 십자 방향 (상, 하, 좌, 우)
<<<<<<< HEAD
    assign shift_l = (start_pos_board & MASK_NOT_LEFT)  >> 1;
    assign shift_r = (start_pos_board & MASK_NOT_RIGHT) << 1;
    assign shift_u = start_pos_board >> 8;
    assign shift_d = start_pos_board << 8;

    // 2. 대각선 방향 (상좌, 상우, 하좌, 하우)
    assign shift_ul = (start_pos_board & MASK_NOT_LEFT)  >> 9;
    assign shift_ur = (start_pos_board & MASK_NOT_RIGHT) >> 7;
    assign shift_dl = (start_pos_board & MASK_NOT_LEFT)  << 7;
    assign shift_dr = (start_pos_board & MASK_NOT_RIGHT) << 9;
=======
    assign shift_l = (dep_pos_board & MASK_NOT_LEFT)  >> 1;
    assign shift_r = (dep_pos_board & MASK_NOT_RIGHT) << 1;
    assign shift_u = dep_pos_board << 5; // 폰 코드(bit0=a1)와 방향을 맞추기 위해 << 5
    assign shift_d = dep_pos_board >> 5; // 폰 코드(bit0=a1)와 방향을 맞추기 위해 >> 5

    // 2. 대각선 방향 (상좌, 상우, 하좌, 하우)
    assign shift_ul = (dep_pos_board & MASK_NOT_LEFT)  << 4;
    assign shift_ur = (dep_pos_board & MASK_NOT_RIGHT) << 6;
    assign shift_dl = (dep_pos_board & MASK_NOT_LEFT)  >> 6;
    assign shift_dr = (dep_pos_board & MASK_NOT_RIGHT) >> 4;
>>>>>>> 13745d405a7b64bccf07790260afdb57c33a3446

    // 3. 8방향 결과를 모두 합침
    assign neighbors = shift_l | shift_r | shift_u | shift_d |
                       shift_ul | shift_ur | shift_dl | shift_dr;

    // 4. 원위치(자기 자신)에 있던 1을 제외
    assign king_move_board = neighbors & ~team_board;

endmodule