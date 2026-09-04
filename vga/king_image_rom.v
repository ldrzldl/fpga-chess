module king_image_rom (
    input  wire [13:0] addr,     // 96x96 = 9216개 주소
    output wire [1:0]  px_info
);

    reg [1:0] memory [0:16384];

    // 시뮬레이션 및 합성 시 파일 로드
    initial begin   
        $readmemb("king_image.mem", memory);
    end

    // 클럭 없는 순수 조합 논리 출력 (assign 연결)
    assign px_info = memory[addr];

endmodule


// module image_rom (
//     input wire clk,
//     input wire [11:0] addr,    // 60x60 = 3600개 주소 필요 (2^12 = 4096)
//     output reg is_bg,
//     output reg is_white
// );

//     // 60x60, 10: 배경, 00: 흑, 01: 백
//     reg [1:0] memory [0:4095];

//     // 시뮬레이션 및 합성 시 .mem 파일 로드
//     initial begin   
//         $readmemb("king_image.mem", memory);
//     end

//     always @(posedge clk) begin
//         is_bg <= memory[addr][1];
//         is_white <= memory[addr][0];
//     end

// endmodule