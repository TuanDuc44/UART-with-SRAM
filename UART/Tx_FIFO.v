module Tx_FIFO #(
    parameter FIFO_WIDTH_T = 9 ,  // 8 bit data + 1 bit parity
    parameter FIFO_DEPTH_T = 16
)(
    input baud_clk ,
    input rst,
    input start_Tx,    
    input start_Rx, 
    input parity_bit, 
    input [7:0] data_in, 
    input Rx_ready,
    output reg TxFF,     
    output reg data_out  
);

    // Bung từng phần tử của FIFO
    reg [FIFO_WIDTH_T-1:0] mem_0;
    reg [FIFO_WIDTH_T-1:0] mem_1;
    reg [FIFO_WIDTH_T-1:0] mem_2;
    reg [FIFO_WIDTH_T-1:0] mem_3;
    reg [FIFO_WIDTH_T-1:0] mem_4;
    reg [FIFO_WIDTH_T-1:0] mem_5;
    reg [FIFO_WIDTH_T-1:0] mem_6;
    reg [FIFO_WIDTH_T-1:0] mem_7;
    reg [FIFO_WIDTH_T-1:0] mem_8;
    reg [FIFO_WIDTH_T-1:0] mem_9;
    reg [FIFO_WIDTH_T-1:0] mem_10;
    reg [FIFO_WIDTH_T-1:0] mem_11;
    reg [FIFO_WIDTH_T-1:0] mem_12;
    reg [FIFO_WIDTH_T-1:0] mem_13;
    reg [FIFO_WIDTH_T-1:0] mem_14;
    reg [FIFO_WIDTH_T-1:0] mem_15;

    reg TxFE;
    reg active_flag;
    reg done_transmission;
    reg [3:0] serial_counter;
    reg [3:0] filling_counter;
    reg [3:0] sending_counter;
    reg [FIFO_WIDTH_T-1:0] bus;
    reg waiting = 1;

    localparam IDLE = 0,
               RECEIVE = 1,
               WAIT = 2,
               ACTIVE = 3;

    reg [1:0] cs, ns;

    // FSM: state memory
    always @(posedge baud_clk or posedge rst) begin
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // FSM: next state logic
    always @(*) begin
        case (cs)
            IDLE: ns = (start_Rx) ? RECEIVE : IDLE;
            RECEIVE: begin
                if (~start_Tx)
                    ns = ACTIVE;
                else if (start_Rx)
                    ns = RECEIVE;
                else
                    ns = WAIT;
            end
            WAIT: begin
                if (~start_Tx)
                    ns = ACTIVE;
                else if (start_Rx)
                    ns = RECEIVE;
                else
                    ns = WAIT;
            end
            ACTIVE: ns = (serial_counter == 9) ? WAIT : ACTIVE;
        endcase
    end

    // Lấy dữ liệu từ mem_x theo sending_counter
    always @(*) begin
        case (sending_counter)
            4'd0:  bus = mem_0;
            4'd1:  bus = mem_1;
            4'd2:  bus = mem_2;
            4'd3:  bus = mem_3;
            4'd4:  bus = mem_4;
            4'd5:  bus = mem_5;
            4'd6:  bus = mem_6;
            4'd7:  bus = mem_7;
            4'd8:  bus = mem_8;
            4'd9:  bus = mem_9;
            4'd10: bus = mem_10;
            4'd11: bus = mem_11;
            4'd12: bus = mem_12;
            4'd13: bus = mem_13;
            4'd14: bus = mem_14;
            4'd15: bus = mem_15;
            default: bus = 0;
        endcase
    end

    // FSM: output logic và lưu vào mem_x khi ghi
    always @(posedge baud_clk) begin
        if (cs == IDLE) begin
            data_out <= 1;
            filling_counter <= 0;
            serial_counter <= 15;
            sending_counter <= 0;
            TxFF <= 0;
            TxFE <= 1;
            active_flag <= 0;
            done_transmission <= 0;
            waiting <= 0;
        end
        else if (cs == RECEIVE) begin
            if (~TxFF) begin
                case (filling_counter)
                    4'd0: mem_0  <= {parity_bit, data_in};
                    4'd1: mem_1  <= {parity_bit, data_in};
                    4'd2: mem_2  <= {parity_bit, data_in};
                    4'd3: mem_3  <= {parity_bit, data_in};
                    4'd4: mem_4  <= {parity_bit, data_in};
                    4'd5: mem_5  <= {parity_bit, data_in};
                    4'd6: mem_6  <= {parity_bit, data_in};
                    4'd7: mem_7  <= {parity_bit, data_in};
                    4'd8: mem_8  <= {parity_bit, data_in};
                    4'd9: mem_9  <= {parity_bit, data_in};
                    4'd10: mem_10 <= {parity_bit, data_in};
                    4'd11: mem_11 <= {parity_bit, data_in};
                    4'd12: mem_12 <= {parity_bit, data_in};
                    4'd13: mem_13 <= {parity_bit, data_in};
                    4'd14: mem_14 <= {parity_bit, data_in};
                    4'd15: mem_15 <= {parity_bit, data_in};
                endcase
                TxFE <= 0;
                waiting <= 0;
                filling_counter <= filling_counter + 1;
                if ((filling_counter + 1 == sending_counter) || ((filling_counter == 15) && (sending_counter == 0)))
                    TxFF <= 1;
            end
        end
        else if (cs == WAIT)
            waiting <= 1;
        else if (cs == ACTIVE) begin
            if (~TxFE || serial_counter != 15) begin
                TxFF <= 0;
                waiting <= 0;
                if (!Rx_ready && done_transmission)
                    serial_counter <= 15;
                else if (serial_counter == 15) begin
                    data_out <= 0;
                    serial_counter <= serial_counter + 1;
                end
                else begin
                    if (serial_counter == 9) begin
                        done_transmission <= 1;
                        data_out <= 1;
                        active_flag <= 0;
                        serial_counter <= 15;
                        sending_counter <= sending_counter + 1;
                    end
                    else begin
                        data_out <= bus[serial_counter];
                        serial_counter <= serial_counter + 1;
                        active_flag <= 1;
                        done_transmission <= 0;
                    end
                    if ((sending_counter + 1 == filling_counter) || ((sending_counter == 15) && (filling_counter == 0)))
                        TxFE <= 1;
                end
            end
        end
    end

endmodule
