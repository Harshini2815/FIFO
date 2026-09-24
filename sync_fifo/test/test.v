/*
------------------------------------------------------------------------------
Testbench: FIFO Sequential Write and Read Verification

Description:
- Resets the FIFO and initializes all input signals.
- Writes sequential data (0 to FIFO_DEPTH-1) until the FIFO is full.
- Reads back all stored data in FIFO order to verify correct functionality.
- Displays each write and read transaction along with the FIFO full/empty flags.
------------------------------------------------------------------------------
*/

module syncfifo_tb;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    reg clk,rst_n;
    reg wr_en,rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty;

    syncfifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        #20 rst_n = 1; // Release reset

        // Write data to FIFO
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            @(posedge clk);
            wr_en = 1;
            wr_data = i;
            @(posedge clk);
            $display("WRITE: time=%0t data=%0d full=%b empty=%b", $time, wr_data, full, empty);
            wr_en = 0;
        end

        // Read data from FIFO
        for (int i = 0; i < FIFO_DEPTH; i++) begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            $display("READ : time=%0t data=%0d full=%b empty=%b",
              $time, rd_data, full, empty);
            rd_en = 0;
        end

        $finish;
    end
endmodule