`timescale 1ps/1ps

module rook_move_generator (
    input  wire [24:0] start_pos_board, // 룩의 현재 위치 (1개 비트만 1)
    input  wire [24:0] team_board,      // 아군 기물들의 위치 합 (아군 칸 이동 방지)
    input  wire [24:0] occupied_board,  // 체스판 위 모든 기물(아군+적군) 위치 (장애물 감지용)
    output wire [24:0] rook_move_board  // 최종 이동 가능 위치
);

    // 가장자리 랩어라운드(Wrap-around) 방지 마스크
    localparam [24:0] MASK_NOT_LEFT  = 25'b11110_11110_11110_11110_11110;
    localparam [24:0] MASK_NOT_RIGHT = 25'b01111_01111_01111_01111_01111;

    // 기물이 없는 빈 칸 비트보드 (광선이 통과할 수 있는 경로)
    wire [24:0] empty = ~occupied_board;

    // 각 방향별 단계적 광선(Ray) 확장 와이어 (5x5 보드이므로 최대 4칸 확장)
    wire [24:0] ray_l_1, ray_l_2, ray_l_3, ray_l_4;
    wire [24:0] ray_r_1, ray_r_2, ray_r_3, ray_r_4;
    wire [24:0] ray_u_1, ray_u_2, ray_u_3, ray_u_4;
    wire [24:0] ray_d_1, ray_d_2, ray_d_3, ray_d_4;

    wire [24:0] ray_l, ray_r, ray_u, ray_d;
    wire [24:0] all_rays;

    // =========================================================================
    // 1. 좌측 방향 탐색 (-X: >> 1)
    // 이전 칸이 empty(빈칸)일 때만 다음 칸으로 전파
    // =========================================================================
    assign ray_l_1 = (start_pos_board  & MASK_NOT_LEFT) >> 1;
    assign ray_l_2 = ((ray_l_1 & empty) & MASK_NOT_LEFT) >> 1;
    assign ray_l_3 = ((ray_l_2 & empty) & MASK_NOT_LEFT) >> 1;
    assign ray_l_4 = ((ray_l_3 & empty) & MASK_NOT_LEFT) >> 1;
    assign ray_l   = ray_l_1 | ray_l_2 | ray_l_3 | ray_l_4;

    // =========================================================================
    // 2. 우측 방향 탐색 (+X: << 1)
    // =========================================================================
    assign ray_r_1 = (start_pos_board  & MASK_NOT_RIGHT) << 1;
    assign ray_r_2 = ((ray_r_1 & empty) & MASK_NOT_RIGHT) << 1;
    assign ray_r_3 = ((ray_r_2 & empty) & MASK_NOT_RIGHT) << 1;
    assign ray_r_4 = ((ray_r_3 & empty) & MASK_NOT_RIGHT) << 1;
    assign ray_r   = ray_r_1 | ray_r_2 | ray_r_3 | ray_r_4;

    // =========================================================================
    // 3. 위쪽 방향 탐색 (+Y: << 5)
    // =========================================================================
    assign ray_u_1 =  start_pos_board << 5;
    assign ray_u_2 = (ray_u_1 & empty) << 5;
    assign ray_u_3 = (ray_u_2 & empty) << 5;
    assign ray_u_4 = (ray_u_3 & empty) << 5;
    assign ray_u   = ray_u_1 | ray_u_2 | ray_u_3 | ray_u_4;

    // =========================================================================
    // 4. 아래쪽 방향 탐색 (-Y: >> 5)
    // =========================================================================
    assign ray_d_1 =  start_pos_board >> 5;
    assign ray_d_2 = (ray_d_1 & empty) >> 5;
    assign ray_d_3 = (ray_d_2 & empty) >> 5;
    assign ray_d_4 = (ray_d_3 & empty) >> 5;
    assign ray_d   = ray_d_1 | ray_d_2 | ray_d_3 | ray_d_4;

    // =========================================================================
    // 5. 4방향 결과를 합치고 아군 기물 칸 제외
    // =========================================================================
    assign all_rays = ray_l | ray_r | ray_u | ray_d;

    // 적 기물 칸은 all_rays에 포함되어 있어 잡을 수 있고, 아군 기물 칸은 제외됨
    assign rook_move_board = all_rays & ~team_board;

endmodule
