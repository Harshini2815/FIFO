`timescale 1ns/1ps

module async_fifo_TB;

  parameter FIFO_WIDTH = 8;

  wire [FIFO_WIDTH-1:0] data_out;
  wire full;
  wire empty;
  reg [FIFO_WIDTH-1:0] data_in;
  reg w_en, wclk, wrst_n;
  reg r_en, rclk, rrst_n;

  // Queue to push data_in
  reg [FIFO_WIDTH-1:0] wdata_q[$], wdata;

  asyncfifo #(
    .FIFO_WIDTH(FIFO_WIDTH),
    .FIFO_DEPTH(16)
  ) async_fifo(wclk, rclk, rrst_n, wrst_n, w_en, r_en, data_in, data_out,full,empty);

  // initial begin
  //   #1000000;
  //   $display("TIMEOUT");
  //   $finish;
  // end

  always #10 wclk = ~wclk;
  always #25 rclk = ~rclk;
  
  always @(posedge wclk)
    $display("%0t : wclk", $time);

  always @(posedge rclk)
    $display("%0t : rclk", $time);

  initial begin
    wclk = 1'b0; wrst_n = 1'b0;
    w_en = 1'b0;
    data_in = 0;
    
    repeat(10) @(posedge wclk);
    wrst_n = 1'b1;

    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge wclk);
        w_en = (i%2 == 0)? 1'b1 : 1'b0;
        if (w_en) begin
          data_in = $urandom;
          wdata_q.push_back(data_in);
          $display("%0t Push, queue size = %0d", $time, wdata_q.size());
        end
      end
      #50;
    end
  end

  initial begin
    rclk = 1'b0; rrst_n = 1'b0;
    r_en = 1'b0;

    $display("%0t: Read thread started", $time);

    repeat(20) @(posedge rclk);
    $display("%0t: Releasing read reset", $time);
    rrst_n = 1'b1;

    repeat(2) begin
      $display("%0t: Starting read loop", $time);
      for (int i=0; i<30; i++) begin
        @(posedge rclk);
        r_en = (i%2 == 0)? 1'b1 : 1'b0;
        if (r_en) begin
          $display("%0t Before pop, queue size = %0d", $time, wdata_q.size());
          wdata = wdata_q.pop_front();
          $display("%0t After pop", $time);
          #15
          $display("%0t Comparing", $time);
          if(data_out !== wdata) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out);
          else $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h",$time, wdata, data_out);
        end
      end
      #50;
    end

    $finish;
  end
  
  // initial begin 
  //   $dumpfile("dump.vcd"); $dumpvars(0);
  // end
endmodule
