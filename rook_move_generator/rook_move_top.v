`timescale 1ns / 1ps

module rook_top (
    // [입력 신호]
    input  wire [24:0] rook_board,     // 룩의 현재 위치 (1이 켜진 25비트 보드)
    input  wire [24:0] occupied_board, // 체스판 위 모든 기물(아군+적군)의 위치
    input  wire [24:0] friendly_board, // 아군 기물의 위치
    
    // [출력 신호]
    output wire [24:0] unblocked_moves, // 장애물 무시 이동 경로 (참고/디버깅용)
    output wire [24:0] blocked_moves    // 장애물 고려 최종 이동 경로 (실제 게임용)
);

    // ------------------------------------------------------------------
    // 내부 모듈끼리 데이터를 주고받기 위한 연결선(wire) 선언
    // ------------------------------------------------------------------
    wire [2:0] rook_x;
    wire [2:0] rook_y;
    wire       rook_valid;

    // ------------------------------------------------------------------
    // 1. 위치 변환 모듈 인스턴스화 (Bitboard -> X, Y 좌표)
    // ------------------------------------------------------------------
    bitboard_to_coord u_coord_converter (
        .bitboard (rook_board), // 입력: 룩의 비트보드 위치
        .pos_x    (rook_x),     // 출력: X 좌표
        .pos_y    (rook_y),     // 출력: Y 좌표
        .valid    (rook_valid)  // 출력: 룩 존재 여부
    );

    // ------------------------------------------------------------------
    // 2. 기본 이동 경로 생성 모듈 인스턴스화 (장애물 무시)
    // ------------------------------------------------------------------
    rook_move_generator u_move_gen_unblocked (
        .pos_x         (rook_x),          // 입력: 변환된 X 좌표
        .pos_y         (rook_y),          // 입력: 변환된 Y 좌표
        .valid         (rook_valid),      // 입력: 룩 존재 여부
        .movable_board (unblocked_moves)  // 출력: 장애물 무시 이동 가능 비트보드
    );

    // ------------------------------------------------------------------
    // 3. 실전 이동 경로 생성 모듈 인스턴스화 (장애물 및 아군 고려)
    // ------------------------------------------------------------------
    rook_move_generator_blocked u_move_gen_blocked (
        .pos_x          (rook_x),         // 입력: 변환된 X 좌표
        .pos_y          (rook_y),         // 입력: 변환된 Y 좌표
        .valid          (rook_valid),     // 입력: 룩 존재 여부
        .occupied_board (occupied_board), // 입력: 전체 기물 위치
        .friendly_board (friendly_board), // 입력: 아군 기물 위치
        .movable_board  (blocked_moves)   // 출력: 최종 이동 가능 비트보드
    );

endmodule