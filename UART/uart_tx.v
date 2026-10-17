module uart_tx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_busy,
    output reg        tx_serial
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer COUNTER_WIDTH =(CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    reg [1:0] state;
    reg [COUNTER_WIDTH-1:0] baud_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk) begin

        if (!rst_n) begin
            state     <= IDLE;
            tx_busy   <= 1'b0;
            tx_serial <= 1'b1;
            baud_cnt  <= 0;
            bit_cnt   <= 0;
            shift_reg <= 0;
        end

        else begin

            case (state)

                // IDLE STATE
                IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    baud_cnt  <= 0;
                    bit_cnt   <= 0;

                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_serial <= 1'b0;  // Start bit
                        tx_busy   <= 1'b1;
                        state     <= START;
                    end
                end

                // START BIT
                START: begin
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt  <= 0;
                        tx_serial <= shift_reg[0]; // Data bit 0
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= 0;
                        state     <= DATA;
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                // TRANSMIT 8 DATA BITS, LSB FIRST
                DATA: begin
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 0;

                        if (bit_cnt == 3'd7) begin
                            tx_serial <= 1'b1; // Stop bit
                            state     <= STOP;
                        end
                        else begin
                            tx_serial <= shift_reg[0];
                            shift_reg <= shift_reg >> 1;
                            bit_cnt   <= bit_cnt + 1'b1;
                        end
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                // STOP BIT
                STOP: begin
                    if (baud_cnt == CLKS_PER_BIT - 1) begin
                        baud_cnt <= 0;
                        tx_busy  <= 1'b0;
                        state    <= IDLE;
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: begin
                    state     <= IDLE;
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    baud_cnt  <= 0;
                end

            endcase
        end
    end

endmodule
