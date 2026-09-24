module write_ptr #(
    parameter PTR_WIDTH = 5
)(
    input clk, rstn,
    input write_en,
    input [PTR_WIDTH:0] readptr_g_sync,
    output reg [PTR_WIDTH:0] writeptr_b,
    output reg [PTR_WIDTH:0] writeptr_g,
    output full
);
    wire [PTR_WIDTH:0] next_writeptr_b, next_writeptr_g;

    assign next_writeptr_b = writeptr_b + (write_en & !full);
    assign next_writeptr_g = (next_writeptr_b >> 1) ^ next_writeptr_b;

    assign full = (next_writeptr_g[PTR_WIDTH:PTR_WIDTH-1] != readptr_g_sync[PTR_WIDTH:PTR_WIDTH-1]) & (next_writeptr_g[PTR_WIDTH-2:0] == readptr_g_sync[PTR_WIDTH-2:0]) ;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            writeptr_b <= 0;
            writeptr_g <= 0;
        end else begin
            writeptr_b <= next_writeptr_b;
            writeptr_g <= next_writeptr_g;
        end
    end
endmodule