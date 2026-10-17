module uart_top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx_busy,
    output wire       tx_serial,
    output wire       rx_data_ready,
    output wire [7:0] rx_data,
    output wire       rx_busy
);

    uart_tx u_uart_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx_busy   (tx_busy),
        .tx_serial (tx_serial)
    );

    uart_rx u_uart_rx (
        .clk           (clk),
        .rst_n         (rst_n),
        .rx_serial     (tx_serial),  // Loopback connection
        .rx_data_ready (rx_data_ready),
        .rx_data       (rx_data),
        .rx_busy       (rx_busy)
    );

endmodule
