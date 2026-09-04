module pawn_image_rom (
    input  wire [13:0] addr,     // 96x96 = 9216개 주소
    output wire [1:0]  px_info
);

    reg [1:0] memory [0:16384];

    // 시뮬레이션 및 합성 시 파일 로드
    initial begin   
        $readmemb("pawn_image.mem", memory);
    end

    // 클럭 없는 순수 조합 논리 출력 (assign 연결)
    assign px_info = memory[addr];

endmodule