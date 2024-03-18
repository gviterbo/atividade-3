module sr_s2p ( // shift register, serial to parallel
    input reset,
    input data_in,
    input enable,
    input clk,
    output reg [7:0] data_out,
    output reg ready
);

reg [2:0] size;

always @(posedge clk) begin
    if (reset) begin
        size = 0;
        data_out = 0;
    end else if (enable) begin
        size = size + 1;
        data_out = {data_out[6:0], data_in};
    end
    ready = (size == 7);
end;

endmodule
