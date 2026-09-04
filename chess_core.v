module chess_core (
    input wire clk,
    input wire reset, // 리셋 신호는 항상 활용하는 것이 좋습니다
    input wire up,
    input wire down,
    input wire left,
    input wire right,
    input wire sel,
    output reg is_turn_white,
    output reg [24:0] team_board,
    output reg [24:0] opponent_board,
    output reg [24:0] king_board,
    output reg [24:0] rook_board,
    output reg [24:0] pawn_board   
);

    // 상태 정의
    localparam S_IDLE      = 2'b00; // 시작 위치 선택 전
    localparam S_START_SEL = 2'b01; // 시작 위치 선택 후
    localparam S_UPDATE    = 2'b10; // 도착 위치 선택 후
    localparam S_SWAP_TURN = 2'b11; // 업데이트 후

    reg [1:0] state;
    reg [4:0] cursor, start_pos, end_pos;

    wire [24:0] move_board;

    // 내가 선택한 위치에 내 기물이 있는지 판별하여 제너레이터에 전달
    move_generator mg(
        .is_turn_white(is_turn_white),
        .team_board(team_board),
        .opponent_board(opponent_board),
        .king_board(king_board),
        .rook_board(rook_board),
        .pawn_board(pawn_board),
        .start_pos_board((25'b1 << start_pos) & team_board), // team_board로 수정
        .move_board(move_board)
    );

    // 리셋을 포함한 상태 머신 구성
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            cursor <= 22;

            is_turn_white <= 1'b1;
            king_board     <= 25'b00100_00000_00000_00000_00100;
            rook_board     <= 25'b10001_00000_00000_00000_10001;
            pawn_board     <= 25'b00000_11111_00000_11111_00000;
            team_board     <= 25'b00000_00000_00000_11111_10101;
            opponent_board <= 25'b10101_11111_00000_00000_00000;

        end else begin
            if (up == 1'b1) begin // 오버플로우 해결해야 함.
                cursor <= cursor - 5;
            end else if (down == 1'b1) begin 
                cursor <= cursor + 5;
            end else if (left == 1'b1) begin 
                cursor <= cursor - 1;
            end else if (right == 1'b1) begin 
                cursor <= cursor + 1;
            end

            case (state)
                S_IDLE: begin
                    if (sel == 1'b1 && team_board[cursor] == 1'b1) begin
                        start_pos <= cursor;
                        state <= S_START_SEL;
                    end
                end

                S_START_SEL: begin // 유효한 도착위치라면 업데이트 상태로 변경
                    if (sel == 1'b1) begin 
                        if (move_board[cursor] == 1'b1) begin 
                            end_pos <= cursor;
                            state <= S_UPDATE;
                        end else if ((start_pos != cursor) && team_board[cursor]) begin 
                            start_pos <= cursor;
                        end
                    end
                end

                S_UPDATE: begin // 보드 업데이트
                    team_board     <= (team_board & ~(25'd1 << start_pos)) | (25'd1 << end_pos);
                    opponent_board <= (opponent_board & ~(25'd1 << end_pos));

                    // 2. 기물 이동 및 포획 처리 (end_pos에 있던 상대 기물 비트도 동시 소멸)
                    king_board <= (king_board & ~(25'd1 << start_pos) & ~(25'd1 << end_pos)) | 
                                  (king_board[start_pos] ? (25'd1 << end_pos) : 25'd0);

                    rook_board <= (rook_board & ~(25'd1 << start_pos) & ~(25'd1 << end_pos)) | 
                                  (rook_board[start_pos] ? (25'd1 << end_pos) : 25'd0);

                    pawn_board <= (pawn_board & ~(25'd1 << start_pos) & ~(25'd1 << end_pos)) | 
                                  (pawn_board[start_pos] ? (25'd1 << end_pos) : 25'd0);


                    state <= S_SWAP_TURN;
                end 

                S_SWAP_TURN: begin // 턴 교체
                    is_turn_white <= ~is_turn_white;
                    team_board <= opponent_board;
                    opponent_board <= team_board;
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
