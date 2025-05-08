module Rx_Receiver (
    input baud_clk,
    input rst,
    input [11:0] data_in,     // data from the Rx_FIFO
    input RxFE, receive,      // receive: order signal in Rx_FIFO
    output receive_order,
    output reg [8:0] data_out // 9-bit output (8-bit data + 1 parity)
);

    assign receive_order = receive;

    reg RxFE_reg;

    always @(posedge baud_clk) begin
        RxFE_reg <= RxFE;
    end

    always @(posedge baud_clk or posedge rst) begin
        if (rst)
            data_out <= 9'd0;
        else if (receive && ~RxFE_reg)
            data_out <= data_in[8:0];
    end

endmodule
