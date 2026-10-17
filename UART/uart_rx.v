module uart_rx #(parameter CLK_FREQ = 50_000_000, parameter BAUD_RATE = 9600) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_serial,
    output reg        rx_data_ready,
    output reg [7:0]  rx_data,
    output reg        rx_busy
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
    always @(posedge clk)
    begin
    if(rst_n == 0) 
    begin
        state <= IDLE;
        rx_data_ready <= 1'b0;
        rx_data <= 8'b0;
        rx_busy <= 1'b0;
        baud_cnt <= 0;
        bit_cnt <= 0;
        shift_reg <= 0;
    end 
    else 
    begin
        case (state)
            IDLE: begin
                rx_data_ready <= 1'b0;
                baud_cnt <= 0;
                bit_cnt <= 0;
                if (rx_serial == 1'b0) begin // Start bit detected
                    state <= START;
                    rx_busy <= 1'b1;
                end
            end

            START: begin
                if (baud_cnt == (CLKS_PER_BIT / 2) - 1)
                begin
                    baud_cnt <= 0;
                    if (rx_serial == 1'b0) begin    // CHANGED: added begin
                        state <= DATA;
                    end                             // CHANGED: added end (tx_busy line removed)
                    else begin                      // CHANGED: added begin
                        state <= IDLE;
                        rx_busy <= 1'b0;            // ADDED: release busy on false start
                    end                             // CHANGED: added end
                end
                else 
                begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            DATA: begin
                if (baud_cnt == CLKS_PER_BIT - 1) 
                begin
                    baud_cnt <= 0;
                    shift_reg[bit_cnt] <= rx_serial; 
                    if (bit_cnt == 7)
                     begin
                        state <= STOP;
                    end 
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end 
                else 
                begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            STOP: begin
                if (baud_cnt == CLKS_PER_BIT - 1) begin
                    baud_cnt <= 0;
                    rx_data_ready <= 1'b1; // Data is ready to be read
                    rx_data <= shift_reg;   // Output the received data
                    rx_busy <= 1'b0;        // Indicate that the receiver is not busy
                    state <= IDLE;          // Go back to IDLE state
                end 
                else 
                begin
                    baud_cnt <= baud_cnt + 1;
                end
            end

            default: state <= IDLE; // Default case to handle unexpected states

        endcase
    end
    end
    endmodule
