`include "write_ptr.v"
`include "read_ptr.v"
`include "synchronizer.v"
`include "fifo_mem.v"

module asyncfifo #(
    parameter FIFO_WIDTH = 5,
    parameter FIFO_DEPTH = 16,
    parameter PTR_WIDTH = $clog2(FIFO_DEPTH) 
)(
    input write_clk, read_clk, read_rstn, write_rstn,
    input write_en, read_en,
    input [FIFO_WIDTH-1:0] data_in,
    output reg [FIFO_WIDTH-1:0] data_out,
    output reg full, empty
);
    wire [PTR_WIDTH:0] readptr_b, readptr_g, readptr_sync;
    wire [PTR_WIDTH:0] writeptr_b, writeptr_g, writeptr_sync;

    write_ptr #(.PTR_WIDTH(PTR_WIDTH)) write(
        .clk(write_clk), .rstn(write_rstn),
        .write_en(write_en), 
        .readptr_g_sync(readptr_sync),
        .writeptr_b(writeptr_b),
        .writeptr_g(writeptr_g),
        .full(full)
    );

    read_ptr #(.PTR_WIDTH(PTR_WIDTH)) read(
        .clk(read_clk), .rstn(read_rstn),
        .read_en(read_en),
        .writeptr_g_sync(writeptr_sync),
        .readptr_b(readptr_b),
        .readptr_g(readptr_g),
        .empty(empty)
    );

    synchronizer #(.PTR_WIDTH(PTR_WIDTH)) sync_write(
        .clk(write_clk),
        .rstn(write_rstn),
        .ptr_in(readptr_g),
        .ptr_out(readptr_sync)
    );

    synchronizer #(.PTR_WIDTH(PTR_WIDTH)) sync_read(
        .clk(read_clk),
        .rstn(read_rstn),
        .ptr_in(writeptr_g),
        .ptr_out(writeptr_sync)
    );

    fifo_memory #(
        .PTR_WIDTH(PTR_WIDTH),
        .FIFO_WIDTH(FIFO_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) fifo_mem (
        .write_clk(write_clk), 
        .read_clk(read_clk),
        .read_en(read_en),
        .write_en(write_en),
        .full(full), .empty(empty),
        .read_ptr_b(readptr_b),
        .write_ptr_b(writeptr_b),
        .data_in(data_in),
        .data_out(data_out)
    );

endmodule