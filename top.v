`timescale 1ps/1ps

module top (
    input wire reset, // 리셋 신호는 항상 활용하는 것이 좋습니다
    input wire clk,
    input wire sel
);

    // 상태 정의
    localparam S_IDLE      = 2'b00; // 시작 위치 선택 전
    localparam S_START_SEL = 2'b01; // 시작 위치 선택 후
    localparam S_UPDATE    = 2'b10; // 도착 위치 선택 후
    localparam S_SWAP_TURN = 2'b11; // 업데이트 후

    reg [1:0] state;

    reg [24:0] opponent_board;
    reg [24:0] team_board;
    reg [24:0] king_board;
    reg [24:0] rook_board;
    reg [24:0] pawn_board;
    
    // 배열 인덱스용이므로 5비트로 선언 (0~24 표현)
    reg [4:0] start_pos; 
    reg [4:0] end_pos; 
    reg [24:0] start_pos_board;
    
    wire [24:0] move_board;

    // 내가 선택한 위치에 내 기물이 있는지 판별하여 제너레이터에 전달
    move_generator mg(
        .opponent_board(opponent_board),
        .team_board(team_board),
        .king_board(king_board),
        .rook_board(rook_board),
        .pawn_board(pawn_board),
        .start_pos_board(start_pos_board & team_board), // team_board로 수정
        .move_board(move_board)
    );

    integer i;

    // 리셋을 포함한 상태 머신 구성
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            // 여기에 보드 초기화 로직 추가 필요
        end else begin
            case (state)
                S_START_SEL: begin // 유효한 도착위치라면 업데이트 상태로 변경
                    if (sel == 1'b1) begin 
                        if (move_board[end_pos] == 1'b1) begin 
                            state <= S_UPDATE;
                        end else begin 
                            state <= S_START_SEL;
                        end
                    end
                end

                S_UPDATE: begin // 보드 업데이트
                    // 1. 출발지 비우기
                    team_board[start_pos] <= 1'b0;
                    king_board[start_pos] <= 1'b0;
                    rook_board[start_pos] <= 1'b0;
                    pawn_board[start_pos] <= 1'b0;

                    // 2. 도착지 채우기
                    team_board[end_pos] <= 1'b1;
                    opponent_board[end_pos] <= 1'b0; 
                    
                    if (king_board[start_pos] == 1'b1) begin 
                        king_board[end_pos] <= 1'b1;
                    end else if (rook_board[start_pos] == 1'b1) begin 
                        rook_board[end_pos] <= 1'b1;
                    end else begin 
                        pawn_board[end_pos] <= 1'b1;
                    end
                    
                    // 3. 업데이트 완료 후 턴 스위치 상태로 이동
                    state <= S_SWAP_TURN;
                end 

                S_SWAP_TURN: begin // 턴 교체
                    // 기물 이동이 완전히 끝난 다음 클럭에서 보드 시점 교환
                    for (i = 0; i < 25; i = i + 1) begin 
                        opponent_board[i] <= team_board[i];
                        team_board[i] <= opponent_board[i];
                    end
                    // 턴 교체가 끝나면 다시 대기/선택 상태로 돌아감
                    state <= S_IDLE; 
                end
            endcase
        end
    end

endmodule
