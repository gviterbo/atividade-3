module spi_sub (
    input reset,
    input [7:0] data_in,
    input load,
    output reg [7:0] data_out,
    output reg ready,
    output reg done,
    input mosi,
    output reg miso,
    input sclk,
    input cs
);

// Registradores para controle interno
reg [7:0] shift_reg_in; // Registro de deslocamento para entrada
reg [7:0] shift_reg_out; // Registro de deslocamento para saída
reg [2:0] bit_count = 0; // Contador de bits
reg load_reg = 0; // Indica que o dado foi carregado

// Processamento na borda de descida do sclk e controle por cs
always @(negedge sclk or posedge reset) begin
    if (reset) begin
        // Reseta o estado do módulo
        shift_reg_in <= 0;
        shift_reg_out <= 0;
        data_out <= 0;
        ready <= 0;
        done <= 0;
        miso <= 1'b0;
        bit_count <= 0;
        load_reg <= 0;
    end else if (!cs) begin
        // cs ativo
        if (load && !load_reg) begin
            // Carrega o dado para transmissão
            shift_reg_out <= data_in;
            load_reg <= 1;
            done <= 1; // Indica que o dado de entrada foi lido
        end else if (load_reg) begin
            // Transmite e recebe dados
            if (bit_count < 8) begin
                miso <= shift_reg_out[7]; // Envia o bit mais significativo
                shift_reg_out <= shift_reg_out << 1; // Desloca para preparar o próximo bit
                shift_reg_in <= (shift_reg_in << 1) | mosi; // Recebe o próximo bit
                bit_count <= bit_count + 1;
            end
            if (bit_count == 7) begin
                // Transmissão/recepção completa
                ready <= 1; // Dados recebidos disponíveis
                data_out <= shift_reg_in; // Transfere os dados recebidos
                bit_count <= 0; // Reseta o contador para a próxima operação
                load_reg <= 0; // Reseta o indicador de carga
            end
        end
    end else if (cs) begin
        // cs inativo, prepara para a próxima transmissão
        done <= 0;
        ready <= 0;
    end
end

endmodule
