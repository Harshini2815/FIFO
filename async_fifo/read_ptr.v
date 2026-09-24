module read_ptr #(
    parameter PTR_WIDTH = 5
)(
    input clk, rstn,
    input read_en,
    input [PTR_WIDTH:0] writeptr_g_sync,
    output reg [PTR_WIDTH:0] readptr_b,
    output reg [PTR_WIDTH:0] readptr_g,
    output empty
);
    wire [PTR_WIDTH:0] next_readptr_b, next_readptr_g;

    assign next_readptr_b = readptr_b + (read_en & !empty);
    assign next_readptr_g = (next_readptr_b >> 1) ^ next_readptr_b;
    assign empty = writeptr_g_sync == next_readptr_g;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            readptr_b <= 0;
            readptr_g <= 0;
        end else begin
            readptr_b <= next_readptr_b;
            readptr_g <= next_readptr_g;
        end
    end
endmodule