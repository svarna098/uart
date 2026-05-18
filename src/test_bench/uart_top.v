module top #(parameter freq=50000000, baudr=2400, width=8)(
    input sys_clk,
    input sys_rst,
    input xmit_h,
    input [width-1:0] xmit_data_h,
    input uart_rec_data_h,
    output uart_clk,
    output uart_xmit_data_h,
    output xmit_done_h,
    output [width-1:0] rec_data_h,
    output rec_ready,
    output rec_busy,
    output xmit_active
);
    baud_rate #(.freq(freq),.baudr(baudr)) b1 (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .uart_clk(uart_clk)
    );
    u_transmitter #(.width(width)) b2 (
        .uart_clk(uart_clk),
        .sys_rst(sys_rst),
        .xmit_h(xmit_h),
        .xmit_data_h(xmit_data_h),
        .xmit_active(xmit_active),
        .xmit_done_h(xmit_done_h),
        .uart_xmit_data_h(uart_xmit_data_h)
    );
    u_receiver #(.width(width)) b3 (
        .uart_clk(uart_clk),
        .sys_rst(sys_rst),
        .uart_rec_data_h(uart_xmit_data_h),
        .rec_ready(rec_ready),
        .rec_busy(rec_busy),
        .rec_data_h(rec_data_h)
    );
endmodule

