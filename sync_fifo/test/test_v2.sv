/*
------------------------------------------------------------------------------
Testbench: Concurrent FIFO Push and Pop Operations

Description:
- Verifies FIFO functionality under simultaneous write and read operations.
- Generates random input data and performs concurrent push/pop transactions.
- Checks FIFO behavior during full and empty conditions.
- Displays transaction details and FIFO status flags while generating a VCD
  waveform for debugging.
------------------------------------------------------------------------------
*/

module sync_fifo_TB;
  parameter DATA_WIDTH = 8;
  parameter FIFO_DEPTH = 16;
 
  reg clk, rst_n;
  reg w_en, r_en;
  reg [7:0] data_in;
  wire [7:0] data_out;
  wire full, empty;
  
  syncfifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(w_en),
        .rd_en(r_en),
        .wr_data(data_in),
        .rd_data(data_out),
        .full(full),
        .empty(empty)
    );
  
  always #2 clk = ~clk;
  initial begin
    clk = 0; rst_n = 0;
    w_en = 0; r_en = 0;
    #3 rst_n = 1;
    drive(20);
    drive(40);
    $finish;
  end
  
  task push();
    if(!full) begin
      w_en = 1;
      data_in = $random;
      #1 $display("Push In: w_en=%b, r_en=%b, data_in=%h, full=%b, empty=%b",w_en, r_en,data_in, full, empty);
    end
    else $display("FIFO Full!! Can not push data_in=%d", data_in);
  endtask 
  
  task pop();
    if(!empty) begin
      r_en = 1;
      #1 $display("Pop Out: w_en=%b, r_en=%b, data_out=%h, full=%b, empty=%b",w_en, r_en,data_out, full, empty);
    end
    else $display("FIFO Empty!! Can not pop data_out");
  endtask
  
  task drive(int delay);
    w_en = 0; r_en = 0;
    fork
      begin
        repeat(10) begin @(posedge clk) push(); end
        w_en = 0;
      end
      begin
        #delay;
        repeat(10) begin @(posedge clk) pop(); end
        r_en = 0;
      end
    join
  endtask
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
