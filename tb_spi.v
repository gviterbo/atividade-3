module tb_spi();

// Sinais gerais
reg clk;
reg reset;

// Sinais para o Principal (Main)
reg [7:0] mdata_in;
wire [7:0] mdata_out;
reg mload;
wire mready, mdone; 

// Sinais de comunicação entre os módulos
wire mosi, miso, sclk, cs;

// Sinais do Secundário (Sub)
reg [7:0] sdata_in;
wire [7:0] sdata_out;
reg sload;
wire sready, sdone;

spi_main spm(
    .clk(clk),
    .reset(reset),
    .data_in(mdata_in),
    .load(mload),
    .data_out(mdata_out),
    .ready(mready),
    .done(mdone),
    .mosi(mosi),
    .miso(miso),
    .sclk(sclk),
    .cs(cs)
);

spi_sub sps(
    .reset(reset),
    .data_in(sdata_in),
    .load(sload),
    .data_out(sdata_out),
    .ready(sready),
    .done(sdone),
    .mosi(mosi),
    .miso(miso),
    .sclk(sclk),
    .cs(cs)
);

always #1 clk = (clk===1'b0);

initial begin
  $dumpfile("tb_spi.vcd");
  $dumpvars(0, tb_spi);

  reset = 1;
  mload = 0; mdata_in = 0; 
  sload = 0; sdata_in = 0;

  #10 reset = 0;
  #1;
  mload = 1; mdata_in = 8'b10101010;
  #2 mload = 0;

  #20;

  mload = 1; mdata_in = 8'b11001100;
  #2 mload = 0;

  #20;

  sload = 1; sdata_in = 8'b11110000;
  #2 sload = 0;

  #20;

  sload = 1; sdata_in = 8'b00001111;
  #2 sload = 0;

  #20;

  $finish;
end

// Só imprime os sinais de saída quando um dos dois ready é 1
initial begin
  forever begin
    if (mready) begin
      $display("mready=%b, mdata_out=%b", mready, mdata_out);
    end
    if (sready) begin
      $display("sready=%b, sdata_out=%b", sready, sdata_out);
    end
    #2;
  end
end

endmodule
