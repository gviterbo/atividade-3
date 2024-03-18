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

// Contador para controlar os bits enviados/recebidos
reg [2:0] bit_count;

// Registrador para armazenar o valor temporário durante a transmissão/recepção
reg [7:0] temp_data_out;

// Sinal para controlar o clock do SPI (sclk)
reg toggle_sclk;

// Lógica de controle principal
always @(posedge clk) begin
    if (reset) begin
        // Reinicializa os registros e sinais
        bit_count <= 3'b111; // Inicia em 7 para contar 8 bits
        done <= 0;
        ready <= 0;
        mosi <= 0;
        sclk <= 0;
        cs <= 1; // Desativa a comunicação SPI
        toggle_sclk <= 0;
        temp_data_out <= 0;
    end
    else if (load) begin
        // Prepara para iniciar a transmissão
        cs <= 0; // Ativa a comunicação SPI
        temp_data_out <= data_in; // Carrega o dado para ser enviado
        bit_count <= 3'b111; // Reinicia a contagem de bits
    end
    else if (!cs) begin
        if (bit_count != 3'b111 || toggle_sclk) begin // Após o primeiro ciclo de load ou na alternância do sclk
            toggle_sclk <= !toggle_sclk; // Alterna o sclk
            sclk <= toggle_sclk; // Atualiza o sclk com a alternância

            if (toggle_sclk) begin
                // Na transição de baixa para alta do sclk, envia e recebe bits
                mosi <= temp_data_out[7]; // Envia o bit mais significativo
                temp_data_out <= temp_data_out << 1; // Desloca o registrador para o próximo bit
                temp_data_out[0] <= miso; // Lê o bit do MISO e armazena no bit menos significativo

                if (bit_count == 0) begin
                    // Finaliza a transmissão/recepção
                    cs <= 1; // Desativa a comunicação SPI
                    done <= 1; // Sinaliza que a transmissão foi concluída
                    ready <= 1; // Sinaliza que os dados recebidos estão prontos
                    data_out <= temp_data_out; // Atualiza data_out com os dados recebidos
                end
                bit_count <= bit_count - 1; // Decrementa o contador de bits
            end
        end
    end
    else begin
        // Reseta os sinais de controle após a conclusão da transmissão/recepção
        done <= 0;
        ready <= 0;
    end
end

endmodule
