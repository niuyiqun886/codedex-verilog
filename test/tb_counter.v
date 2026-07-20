`timescale 1ns/1ps
module tb_counter;
    reg clk, rst_n;
    wire [3:0] cnt;
    counter u_counter (.clk(clk), .rst_n(rst_n), .cnt(cnt));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        #20 rst_n = 1;
        repeat (20) @(posedge clk)
            $display("time=%0t  cnt=%d", $time, cnt);
        $finish;
    end
endmodule