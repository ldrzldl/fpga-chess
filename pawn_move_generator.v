`timescale 1ps/1ps

module pawn_move_generator (
    input  wire [24:0] dep_pos_board, // 현재 폰 위치 (25‑bit, 하나만 1)
    input  wire        is_white,      // 1 = 백(위쪽 이동), 0 = 흑(아래쪽 이동)
    input  wire [24:0] team_board,    // 우리 팀(아군) 기물들의 비트보드
    input  wire [24:0] enemy_board,   // 적 팀(상대) 기물들의 비트보드
    output wire [24:0] pawn_move_board // 폰이 이동 가능하거나 잡을 수 있는 위치들의 비트보드
);

    // 가장자리 랩어라운드 방지용 마스크
    localparam [24:0] MASK_NOT_LEFT  = 25'b11110_11110_11110_11110_11110; 
    localparam [24:0] MASK_NOT_RIGHT = 25'b01111_01111_01111_01111_01111; 

    wire [24:0] empty_squares = ~(team_board | enemy_board); // 빈 칸 계산

    // 백: 위로(<<) 전진
    wire [24:0] w_forward = (dep_pos_board << 5) & empty_squares;
    wire [24:0] w_atk_l   = ((dep_pos_board & MASK_NOT_LEFT) << 4) & enemy_board;
    wire [24:0] w_atk_r   = ((dep_pos_board & MASK_NOT_RIGHT) << 6) & enemy_board;

    // 흑: 아래로(>>) 전진
    wire [24:0] b_forward = (dep_pos_board >> 5) & empty_squares;
    wire [24:0] b_atk_l   = ((dep_pos_board & MASK_NOT_LEFT) >> 6) & enemy_board;
    wire [24:0] b_atk_r   = ((dep_pos_board & MASK_NOT_RIGHT) >> 4) & enemy_board;

    assign pawn_move_board = is_white ? (w_forward | w_atk_l | w_atk_r)
                                      : (b_forward | b_atk_l | b_atk_r);

endmodule
