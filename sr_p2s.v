module sr_p2s ( // shift register, parallel to serial
    input reset,
    input clk,
    input [7:0] data_in,
    input load,
    output reg data_out,
    output reg ready
);

reg [2:0] size;
reg [7:0] data_out_reg;

always @(posedge clk) begin
    if (reset) begin
        size = 0;
        data_out_reg = 0;
    end else if (load) begin
        size = 7;
        data_out_reg = data_in;
    end else if (size != 0) begin
        size = size - 1;
        data_out_reg = {data_out_reg[6:0], 1'b0};
    end else begin
        data_out_reg = 0;
    end
    ready = (size == 0);
    data_out = data_out_reg[7];
end

endmodule
