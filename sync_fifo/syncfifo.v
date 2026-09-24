/*
------------------------------------------------------------------------------
Synchronous FIFO

Description:
- Parameterized synchronous FIFO with configurable data width and depth.
- Supports single-clock read/write operations with full and empty flag
  generation using circular read and write pointers.
------------------------------------------------------------------------------
*/

module syncfifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] wr_data,
    output reg [DATA_WIDTH-1:0] rd_data,
    output wire full,
    output wire empty
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr; // Write pointer with an extra bit for full/empty detection
    reg [$clog2(FIFO_DEPTH):0] rd_ptr; // Read pointer with an extra bit for full/empty detection

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            rd_data <= 0;
        end else begin
            if (wr_en && !full) begin
                fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end

            if (rd_en && !empty) begin
                rd_data <= fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    assign full = (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]) && (wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]);
    assign empty = (wr_ptr == rd_ptr);

endmodule
