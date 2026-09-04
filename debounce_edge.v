module debounce_edge (
    input  wire clk,       // 25MHz 시스템 클럭
    input  wire reset,
    input  wire btn_in,    // 채터링이 포함된 외부 버튼 신호
    output reg  btn_pulse  // 1클럭 주기 동안만 발생하는 정제된 출력
);

    // 1. 메타안정성 방지를 위한 2단 동기화기
    reg sync_0, sync_1;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    // 2. 20ms 카운터 기반 디바운스 필터
    // 25MHz 기준 500,000 클럭 = 20ms
    localparam COUNT_MAX = 500_000 - 1;
    reg [18:0] counter;
    reg        btn_state; // 디바운스된 안정적인 버튼 레벨

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter   <= 19'd0;
            btn_state <= 1'b0;
        end else begin
            // 입력 신호가 현재 인식된 상태와 다르면 카운터 동작
            if (sync_1 != btn_state) begin
                if (counter == COUNT_MAX) begin
                    // 노이즈 없이 20ms 동안 값이 유지되었을 때만 새 상태로 인정
                    counter   <= 19'd0;
                    btn_state <= sync_1;
                end else begin
                    counter   <= counter + 1'b1;
                end
            end else begin
                // 입력 신호가 다시 원래 상태로 튀면 카운터 리셋
                counter <= 19'd0;
            end
        end
    end

    // 3. 1클럭 사이클 원펄스(One-pulse) 상승 에지 검출
    reg btn_state_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_state_prev <= 1'b0;
            btn_pulse      <= 1'b0;
        end else begin
            btn_state_prev <= btn_state;
            // 이전 클럭엔 0이고 현재 클럭엔 1인 순간에만 1클럭 동안 High 출력
            btn_pulse      <= btn_state && !btn_state_prev;
        end
    end

endmodule