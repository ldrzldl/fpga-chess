module color_generator (
    input wire [4:0] square_index,
    input wire is_square_white,
    input wire [13:0] local_px_index,
    input wire board_on,
    input wire is_turn_white,
    input wire [24:0] team_board,
    input wire [24:0] opponent_board,
    input wire [24:0] king_board,
    input wire [24:0] rook_board,
    input wire [24:0] pawn_board,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

    localparam BLACK = 12'h000;
    localparam WHITE = 12'hFFF;
    localparam BG_BLACK = 12'h422;
    localparam BG_WHITE = 12'h744;

    wire [1:0] king_px_info, rook_px_info, pawn_px_info;
    reg [11:0] color;

    king_image_rom kir (
        .addr(local_px_index),
        .px_info(king_px_info)
    );

    rook_image_rom rir (
        .addr(local_px_index),
        .px_info(rook_px_info)
    );

    pawn_image_rom pir (
        .addr(local_px_index),
        .px_info(pawn_px_info)
    );

    // [1] = is_bg, [0] = is_white
    wire [1:0] px_info = king_board[square_index] ? king_px_info :
                         rook_board[square_index] ? rook_px_info :
                         pawn_board[square_index] ? pawn_px_info :
                         2'b10;
    
    wire is_piece_white = (is_turn_white && team_board[square_index]) || 
                     (!is_turn_white && opponent_board[square_index]);

    always @(*) begin 
        if (!board_on)
            color = BLACK;
        else if (px_info[1]) begin
            if (is_square_white)
                color = BG_WHITE;
            else
                color = BG_BLACK;
        end else begin
            if (px_info[0] ^ is_piece_white)
                color = BLACK;
            else
                color = WHITE;
        end
    end

    assign {red, green, blue} = color;

endmodule