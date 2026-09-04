module square_info_generator (
    // input wire clk_25MHz,
    // input wire reset,
    input wire [9:0] px_x,
    input wire [9:0] px_y,
    output wire [4:0] square_index,
    output wire is_square_white,
    output wire [13:0] local_px_index,
    output wire board_on
);

    localparam square_size = 96; // 480 / 5
    localparam grid_size = 5;
    localparam board_size = square_size * grid_size;

    wire [2:0] grid_x = (px_x < square_size)  ? 3'd0 :
                        (px_x < square_size * 2) ? 3'd1 :
                        (px_x < square_size * 3) ? 3'd2 :
                        (px_x < square_size * 4) ? 3'd3 : 3'd4;

    wire [2:0] grid_y = (px_y < square_size)  ? 3'd0 :
                        (px_y < square_size * 2) ? 3'd1 :
                        (px_y < square_size * 3) ? 3'd2 :
                        (px_y < square_size * 4) ? 3'd3 : 3'd4;

    wire [6:0] local_px_x = px_x - (grid_x * square_size);
    wire [6:0] local_px_y = px_y - (grid_y * square_size);

    assign square_index = grid_y * grid_size + grid_x;
    assign is_square_white = grid_x[0] ^ grid_y[0];
    assign local_px_index = local_px_y * square_size + local_px_x;
    assign board_on = (px_x < board_size && px_y < board_size);

endmodule

//     always @(posedge clk_25MHz or posedge reset) begin
//         if (reset) begin
//             square_px_x <= square_size_px - 1;
//             square_px_y <= square_size_px - 1;
//             grid_x <= board_size - 1;
//             grid_y <= board_size - 1;
//         end else begin
//             if (px_x == HT - 1) begin
//                 square_px_x <= square_size_px - 1;
//                 grid_x <= board_size - 1;
//                 if (px_y == VT - 1) begin
//                     square_px_y <= square_size_px - 1;
//                     grid_y <= board_size - 1;
//                 end else if (square_px_y == 0) begin
//                     square_px_y = square_size_px - 1;
//                     grid_y <= grid_y - 1;
//                 end else begin
//                     square_px_y <= square_px_y - 1;
//                 end
//             end else if (square_px_x == 0) begin
//                 square_px_x <= square_size_px - 1;
//                 grid_x <= grid_x - 1;
//             end else begin 
//                 square_px_x <= square_px_x - 1;
//             end
//         end
//     end