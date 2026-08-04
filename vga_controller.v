module vga_controller (
    input wire clk_25MHz,     // 25MHz 픽셀 클럭
    input wire reset,
    output reg hsync,
    output reg vsync,
    output wire [9:0] pixel_x, // 현재 X 좌표 (0 ~ 639)
    output wire [9:0] pixel_y, // 현재 Y 좌표 (0 ~ 479)
    output wire video_on       // 화면 표시 가능 구간 (Active Area)
);

    // 타이밍 파라미터
    localparam HD = 640, HF = 16, HS = 96, HB = 48, HT = 800;
    localparam VD = 480, VF = 10, VS = 2,  VB = 33, VT = 525;

    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    // 수평/수직 카운터
    always @(posedge clk_25MHz or posedge reset) begin
        if (reset) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == HT - 1) begin
                h_cnt <= 0;
                if (v_cnt == VT - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    // 동기화 신호 생성 (Negative Sync)
    always @(*) begin
        hsync = ~((h_cnt >= (HD + HF)) && (h_cnt < (HD + HF + HS)));
        vsync = ~((v_cnt >= (VD + VF)) && (v_cnt < (VD + VF + VS)));
    end

    // 현재 픽셀 좌표 및 Active Area 신호
    assign pixel_x  = h_cnt;
    assign pixel_y  = v_cnt;
    assign video_on = (h_cnt < HD) && (v_cnt < VD);

endmodule