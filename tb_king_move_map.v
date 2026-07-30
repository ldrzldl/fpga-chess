`timescale 1ns / 1ps

module tb_king_move_map;

    // 입력 및 출력 레지스터/와이어 선언
    reg  [63:0] grid_in;
    reg [63:0] team_piece;
    wire [63:0] grid_out;

    // 검증할 모듈(UUT) 인스턴스화
    king_move_map uut (
        .grid_in(grid_in),
        .team_piece(team_piece),
        .grid_out(grid_out)
    );

    initial begin
        // 초기화
        grid_in = 64'h0;
        team_piece = 64'h0;
        #10;

        // 테스트 케이스 1: 격자 중앙 (3행 3열, 27번 비트)
        // 정상적인 8방향 확장이 일어나는지 확인
        grid_in = 64'h0000_0000_0800_0000; 
        #10;
        $display("TC1 (Center)      | IN: %016X | OUT: %016X", grid_in, grid_out);

        // 테스트 케이스 2: 좌측 상단 모서리 (0행 0열, 0번 비트)
        // 위쪽과 왼쪽으로 넘어가지 않고 3개의 주변 비트만 생성되는지 확인
        grid_in = 64'h0000_0000_0000_0001;
        #10;
        $display("TC2 (Top-Left)    | IN: %016X | OUT: %016X", grid_in, grid_out);

        // 테스트 케이스 3: 우측 하단 모서리 (7행 7열, 63번 비트)
        // 아래쪽과 오른쪽으로 넘어가지 않는지 확인
        grid_in = 64'h8000_0000_0000_0000;
        #10;
        $display("TC3 (Bottom-Right)| IN: %016X | OUT: %016X", grid_in, grid_out);

        // 테스트 케이스 4: 우측 테두리 (1행 7열, 15번 비트)
        // 오른쪽 끝에서 다음 줄(왼쪽 끝)로 랩어라운드 되지 않는지 확인
        grid_in = 64'h0000_0000_0000_8000;
        #10;
        $display("TC4 (Right Edge)  | IN: %016X | OUT: %016X", grid_in, grid_out);

        // 테스트 케이스 5: 중간, 같은 팀 피스 (3행 3열, 27번 비트, 아래쪽 세칸 같은 팀 피스)
        // 같은 팀 피스가 있는 곳은 잘 거르는지 확인
        grid_in = 64'h0000_0000_0800_0000;
        team_piece = 64'h0000_0000_001c_0000;
        #10;
        $display("TC5 (Team Piece)  | IN: %016X | OUT: %016X", grid_in, grid_out);

        $finish; // 시뮬레이션 종료
    end

endmodule