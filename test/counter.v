module counter (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [3:0] cnt
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cnt <= 4'd0;
        else
            cnt <= cnt + 1'b1;
    end
endmodule