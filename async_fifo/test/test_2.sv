`timescale 1ns/1ps

module async_fifo_TB;

  parameter DATA_WIDTH = 8;

  wire [DATA_WIDTH-1:0] data_out;
  wire full;
  wire empty;

  reg [DATA_WIDTH-1:0] data_in;
  reg w_en, wclk, wrst_n;
  reg r_en, rclk, rrst_n;

  reg [DATA_WIDTH-1:0] wdata_q[$];
  reg [DATA_WIDTH-1:0] wdata;

  asyncfifo #(
    .FIFO_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(16)
  )as_fifo (
      .write_clk(wclk),
      .write_rstn(wrst_n),
      .read_clk(rclk),
      .read_rstn(rrst_n),
      .write_en(w_en),
      .read_en(r_en),
      .data_in(data_in),
      .data_out(data_out),
      .full(full),
      .empty(empty)
  );

  always #10 wclk = ~wclk;
  always #35 rclk = ~rclk;

  //----------------------------------------
  // WRITE PROCESS
  //----------------------------------------
  initial begin
    wclk    = 0;
    wrst_n  = 0;
    w_en    = 0;
    data_in = 0;

    repeat(10) @(posedge wclk);
    wrst_n = 1;

    repeat(2) begin
      for (int i=0; i<30; i++) begin

        @(negedge wclk);

        w_en = (i%2 == 0);

        if (w_en && !full)
          data_in = $urandom;

        @(posedge wclk);

        if (w_en && !full)
          wdata_q.push_back(data_in);
      end

      #50;
    end

    w_en = 0;
  end

  //----------------------------------------
  // READ PROCESS
  //----------------------------------------
  initial begin
    rclk   = 0;
    rrst_n = 0;
    r_en   = 0;

    repeat(20) @(posedge rclk);
    rrst_n = 1;

    // Allow synchronizers to update
    repeat(3) @(posedge rclk);

    repeat(2) begin
      for (int i=0; i<30; i++) begin

        @(negedge rclk);

        r_en = (i%2 == 0);

        @(posedge rclk);

        if (r_en && !empty) begin
          #1;

          wdata = wdata_q.pop_front();

          if (data_out !== wdata)
            $error("Time=%0t Expected=%h Got=%h",
                    $time, wdata, data_out);
          else
            $display("Time=%0t PASS Data=%h",
                     $time, data_out);
        end
      end

      #50;
    end

    $finish;
  end

  //----------------------------------------
  // VCD
  //----------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, async_fifo_TB);
  end

endmodule