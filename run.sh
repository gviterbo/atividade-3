iverilog -o tb_spi tb_spi.v spi_main.v spi_sub.v 
./tb_spi

rm -f spi.out
./tb_spi > spi.out

if diff spi.out spi.ok >/dev/null; then
    echo "OK"
    exit 0
else
    echo "ERRO"
    exit 1
fi
