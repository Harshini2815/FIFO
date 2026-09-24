module synchronizer #(
    parameter PTR_WIDTH = 5
)(
    input clk,
    input rstn,
    input [PTR_WIDTH:0] ptr_in,
    output reg [PTR_WIDTH:0] ptr_out
);

    reg [PTR_WIDTH:0] Q_out;
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            ptr_out <= 0;
            Q_out <= 0;
        end else begin
            ptr_out <= Q_out;
            Q_out <= ptr_in;
        end
    end
endmodule