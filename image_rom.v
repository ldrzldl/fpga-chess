module image_rom (
    input wire clk,
    input wire [13:0] addr,    // 100x100 = 10,000개 주소 필요 (2^14 = 16,384)
    output reg is_white // RGB444 (12-bit)
);

    // 10,000개의 12비트 데이터를 저장하는 ROM 선언
    reg memory [0:9999];

    // 시뮬레이션 및 합성 시 .mem 파일 로드
    initial begin
        $readmemb("image_data.mem", memory);
    end

    always @(posedge clk) begin
        is_white <= memory[addr];
    end

endmodule