module spi_main (
    input clk,
    input reset,
    input [7:0] data_in,
    input load,
    output reg [7:0] data_out,
    output reg ready,
    output reg done,
    output reg mosi,
    input miso,
    output reg sclk,
    output reg cs
);

// Registradores internos
reg [7:0] shift_reg;
reg [2:0] bit_counter; // Contador para os bits a serem transmitidos
reg load_reg;

// Controle do clock SPI (sclk) - gerar em metade da frequência do clk principal
reg clk_divider;
always @(posedge clk) begin
    if (reset) clk_divider <= 0;
    else clk_divider <= ~clk_divider;

    sclk = clk_divider;
end


// Lógica principal
always @(posedge clk) begin
    if (reset) begin
        cs <= 1;
        done <= 0;
        ready <= 0;
        bit_counter <= 0;
        load_reg <= 0;
    end else if (load && !load_reg) begin
        shift_reg <= data_in;
        cs <= 0; // Iniciar transmissão
        bit_counter <= 7;
        load_reg <= 1;
    end else if (load_reg) begin
        if (clk_divider) begin // Na borda de subida de sclk
            mosi <= shift_reg[7];
            shift_reg <= shift_reg << 1;
            if (bit_counter > 0) bit_counter <= bit_counter - 1;
            else begin
                cs <= 1; // Finalizar transmissão
                done <= 1;
                load_reg <= 0;
            end
        end else begin
            done <= 0; // Resetar sinal de 'done' na borda de descida
        end
    end
end

endmodule
