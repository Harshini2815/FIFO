module fifo_memory #(
    parameter PTR_WIDTH = 5,
    parameter FIFO_DEPTH = 16,
    parameter FIFO_WIDTH = 5
)(
    input write_clk, read_clk,
    input read_en,
    input write_en,
    input full, empty,
    input [PTR_WIDTH:0] read_ptr_b,
    input [PTR_WIDTH:0] write_ptr_b,
    input [FIFO_WIDTH-1:0] data_in,
    output reg [FIFO_WIDTH-1:0] data_out
);
    reg [FIFO_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    always @(posedge write_clk) begin
        if (write_en & !full) begin
            fifo_mem[write_ptr_b[PTR_WIDTH-1:0]] <= data_in;
        end
    end

    always @(posedge read_clk) begin
        $display("time=%0t read_en=%b empty=%b read_ptr=%0d",$time, read_en, empty, read_ptr_b);
        if(read_en & !empty) begin
            $display ("READ OCCURRED");
            data_out <= fifo_mem[read_ptr_b[PTR_WIDTH-1:0]];
        end 
    end

endmodule