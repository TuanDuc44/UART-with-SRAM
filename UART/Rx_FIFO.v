// this is SIPO module (Serial in Parallel out)
module Rx_FIFO #(
    parameter FIFO_WIDTH_R = 12, // 8 bits for data, one for parity and three for errors
    parameter FIFO_DEPTH_R = 16
) (
    input baud_clk, rst,
    input data_in,  // serial input data
    input receive_order, // other system is requesting for receive data
    output reg RxFE, // FIFO empty
    output reg Rx_ready, // flag to state that the FIFO is ready for receiving from Tx_FIFO
    output reg [FIFO_WIDTH_R-1:0] data_out // parallel output data
);

    // Replacing memory array with separate registers
    reg [FIFO_WIDTH_R-1:0] Rx_FIFO_0, Rx_FIFO_1, Rx_FIFO_2, Rx_FIFO_3;
    reg [FIFO_WIDTH_R-1:0] Rx_FIFO_4, Rx_FIFO_5, Rx_FIFO_6, Rx_FIFO_7;
    reg [FIFO_WIDTH_R-1:0] Rx_FIFO_8, Rx_FIFO_9, Rx_FIFO_10, Rx_FIFO_11;
    reg [FIFO_WIDTH_R-1:0] Rx_FIFO_12, Rx_FIFO_13, Rx_FIFO_14, Rx_FIFO_15;

    // internal signals
    reg RxFF; // FIFO full
    reg transfer_flag;
    reg done_receiving;
    reg [8:0] R_bus;
    reg [3:0] serial_counter;
    reg [3:0] filling_counter;
    reg [3:0] sending_counter;
    reg [1:0] break_counter;
    reg FE, BE, OE; // UART Errors (Frame Error, Break Error, Overrun Error)

    // FSM
    localparam IDLE = 0, ACTIVE = 1, FILLING = 2, READY = 3, TRANSMITTING = 4;
    reg [2:0] ns, cs;

    // state memory
    always @(posedge baud_clk or posedge rst) begin
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // next state logic
    always @(*) begin
        case (cs)
            IDLE: ns = (data_in == 0) ? ACTIVE : IDLE;
            ACTIVE: ns = (serial_counter == 9) ? FILLING : ACTIVE;
            FILLING: ns = READY;
            READY: ns = (receive_order) ? TRANSMITTING : (data_in == 0) ? ACTIVE : READY;
            TRANSMITTING: ns = (receive_order) ? TRANSMITTING : (data_in == 0) ? ACTIVE : READY;
            default: ns = IDLE;
        endcase
    end

    // output logic
    always @(posedge baud_clk) begin
        if (cs == IDLE) begin
            RxFE <= 1;
            RxFF <= 0;
            serial_counter <= 0;
            filling_counter <= 0;
            sending_counter <= 0;
            break_counter <= 0;
            transfer_flag <= 0;
            done_receiving <= 0;
            Rx_ready <= 0;
            FE <= 0;
            BE <= 0;
            OE <= 0;
        end
        else if (cs == ACTIVE) begin
            Rx_ready <= 0;
            if (~RxFF) begin
                if (serial_counter == 9) begin
                    done_receiving <= 1;
                    transfer_flag <= 0;
                    serial_counter <= 0;
                    if (data_in != 1)
                        FE <= 1;
                end
                else begin
                    R_bus[serial_counter] <= data_in;
                    serial_counter <= serial_counter + 1;
                    transfer_flag <= 1;
                    done_receiving <= 0;
                end
            end
            else
                OE <= 1;
        end
        else if (cs == FILLING) begin
            Rx_ready <= 0;
            if (break_counter == 3)
                BE <= 1;
            else if (R_bus == 0)
                break_counter <= break_counter + 1;
            else begin
                if (~RxFF) begin
                    case (filling_counter)
                        4'd0: Rx_FIFO_0 <= {FE, BE, OE, R_bus};
                        4'd1: Rx_FIFO_1 <= {FE, BE, OE, R_bus};
                        4'd2: Rx_FIFO_2 <= {FE, BE, OE, R_bus};
                        4'd3: Rx_FIFO_3 <= {FE, BE, OE, R_bus};
                        4'd4: Rx_FIFO_4 <= {FE, BE, OE, R_bus};
                        4'd5: Rx_FIFO_5 <= {FE, BE, OE, R_bus};
                        4'd6: Rx_FIFO_6 <= {FE, BE, OE, R_bus};
                        4'd7: Rx_FIFO_7 <= {FE, BE, OE, R_bus};
                        4'd8: Rx_FIFO_8 <= {FE, BE, OE, R_bus};
                        4'd9: Rx_FIFO_9 <= {FE, BE, OE, R_bus};
                        4'd10: Rx_FIFO_10 <= {FE, BE, OE, R_bus};
                        4'd11: Rx_FIFO_11 <= {FE, BE, OE, R_bus};
                        4'd12: Rx_FIFO_12 <= {FE, BE, OE, R_bus};
                        4'd13: Rx_FIFO_13 <= {FE, BE, OE, R_bus};
                        4'd14: Rx_FIFO_14 <= {FE, BE, OE, R_bus};
                        4'd15: Rx_FIFO_15 <= {FE, BE, OE, R_bus};
                        default: ; // do nothing
                    endcase

                    RxFE <= 0;
                    filling_counter <= filling_counter + 1;
                    if ((filling_counter + 1 == sending_counter) || 
                        ((filling_counter == (FIFO_DEPTH_R-1)) && (sending_counter == 0)))
                        RxFF <= 1;
                end
            end
        end
        else if (cs == READY) begin
            Rx_ready <= 1;
        end
        else if (cs == TRANSMITTING) begin
            Rx_ready <= 0;
            if (receive_order && ~RxFE) begin
                case (sending_counter)
                    4'd0: data_out <= Rx_FIFO_0;
                    4'd1: data_out <= Rx_FIFO_1;
                    4'd2: data_out <= Rx_FIFO_2;
                    4'd3: data_out <= Rx_FIFO_3;
                    4'd4: data_out <= Rx_FIFO_4;
                    4'd5: data_out <= Rx_FIFO_5;
                    4'd6: data_out <= Rx_FIFO_6;
                    4'd7: data_out <= Rx_FIFO_7;
                    4'd8: data_out <= Rx_FIFO_8;
                    4'd9: data_out <= Rx_FIFO_9;
                    4'd10: data_out <= Rx_FIFO_10;
                    4'd11: data_out <= Rx_FIFO_11;
                    4'd12: data_out <= Rx_FIFO_12;
                    4'd13: data_out <= Rx_FIFO_13;
                    4'd14: data_out <= Rx_FIFO_14;
                    4'd15: data_out <= Rx_FIFO_15;
                    default: data_out <= 0;
                endcase

                sending_counter <= sending_counter + 1;
                RxFF <= 0;
                if ((sending_counter + 1 == filling_counter) || 
                    ((sending_counter == (FIFO_DEPTH_R-1)) && (filling_counter == 0)))
                    RxFE <= 1;
            end
        end
    end

endmodule
