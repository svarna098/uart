/*module top #(parameter clk_freq=50000000,baud_rate=2400,width=8)(
input sys_clk,
input sys_rst,
input xmit_h,
input [width-1:0] xmit_data_h,
input uart_rec_data_h,
output baud_op_clk,
output uart_xmit_data_h,
output xmit_done_h,
output [width-1:0] rec_data_h,
output rec_ready,
output rec_busy,
output xmit_active
);



baud_rate #(.freq(clk_freq),.baudr(baud_rate)) b1 (.sys_clk(sys_clk),.sys_rst(sys_rst),.uart_clk(baud_op_clk));
uart_tx #(.width(width)) b2(.baud_op_clk(baud_op_clk),.sys_rst(sys_rst),.xmit_h(xmit_h),.xmit_data_h(xmit_data_h),.xmit_active(xmit_active),.xmit_done_h(xmit_done_h),.uart_xmit_data_h(uart_xmit_data_h));
uart_rx #(.width(width)) b3(.baud_op_clk(baud_op_clk),.sys_rst(sys_rst),.uart_rec_data_h(uart_xmit_data_h),.rec_ready(rec_ready),.rec_busy(rec_busy),.rec_data_h(rec_data_h));
endmodule
*//*
module top #(parameter clk_freq=50000000, baud_rate=2400, width=8)(
    input              sys_clk,
    input              sys_rst,
    input              xmit_h,
    input  [width-1:0] xmit_data_h,
    input              uart_rec_data_h,
    output             baud_op_clk,
    output             uart_xmit_data_h,
    output             xmit_done_h,
    output [width-1:0] rec_data_h,
    output             rec_ready,
    output             rec_busy,
    output             xmit_active
);
    baud_rate #(.freq(clk_freq),.baudr(baud_rate)) b1 (
        .sys_clk(sys_clk), .sys_rst(sys_rst), .uart_clk(baud_op_clk)
    );
    uart_tx #(.width(width)) b2 (
        .baud_op_clk(baud_op_clk), .sys_rst(sys_rst),
        .xmit_h(xmit_h), .xmit_data_h(xmit_data_h),
        .xmit_active(xmit_active), .xmit_done_h(xmit_done_h),
        .uart_xmit_data_h(uart_xmit_data_h)
    );
    uart_rx #(.width(width)) b3 (
        .baud_op_clk(baud_op_clk), .sys_rst(sys_rst),
        .uart_rec_data_h(uart_xmit_data_h),   // loopback inside DUT
        .rec_ready(rec_ready), .rec_busy(rec_busy), .rec_data_h(rec_data_h)
    );
endmodule*/
`include "baud_uart.v"
`include "uart_transmitter.v"
`include "uart_receiver.v"
/*
module top #(parameter clk_freq=50000000, baud_rate=2400, width=8)(
    input              sys_clk,
    input              sys_rst,
    input              xmit_h,
    input  [width-1:0] xmit_data_h,
    input              uart_rec_data_h,
    output             baud_op_clk,
    output             uart_xmit_data_h,
    output             xmit_done_h,
    output [width-1:0] rec_data_h,
    output             rec_ready,
    output             rec_busy,
    output             xmit_active
);
    baud_rate #(.freq(clk_freq),.baudr(baud_rate)) b1 (
        .sys_clk  (sys_clk),
        .sys_rst  (sys_rst),
        .uart_clk (baud_op_clk)
    );
    uart_tx #(.width(width)) b2 (
        .baud_op_clk     (baud_op_clk),
        .sys_rst         (sys_rst),
        .xmit_h          (xmit_h),
        .xmit_data_h     (xmit_data_h),
        .xmit_active     (xmit_active),
        .xmit_done_h     (xmit_done_h),
        .uart_xmit_data_h(uart_xmit_data_h)
    );
    uart_rx #(.width(width)) b3 (
        .baud_op_clk     (baud_op_clk),
        .sys_rst         (sys_rst),
        .uart_rec_data_h (uart_rec_data_h),
        .rec_ready       (rec_ready),
        .rec_busy        (rec_busy),
        .rec_data_h      (rec_data_h)
    );
endmodule      */


`include "inc.h"

module uart (

    input  wire             sys_clk,         
    input  wire             sys_rst_l,       

    output wire             uart_clk,      


    output wire             uart_XMIT_dataH, 
    input  wire             xmitH,          
    input  wire [`WL-1:0]   xmit_dataH,     
    output wire             xmit_doneH,     
    output wire             xmit_active,

    input  wire             uart_REC_dataH, 
    output wire [`WL-1:0]   rec_dataH,      
    output wire             rec_readyH,   
    output wire             rec_busy 
);

    baud u_baud_inst (
        .sys_clk   (sys_clk),
        .sys_rst_l (sys_rst_l),
        .uart_clk  (uart_clk)
    );

    u_xmit u_xmit_inst (
        .uart_clk        (uart_clk),
        .sys_rst_l       (sys_rst_l),
        .xmitH           (xmitH),
        .xmit_dataH      (xmit_dataH),
        .uart_XMIT_dataH (uart_XMIT_dataH),
        .xmit_doneH      (xmit_doneH),
        .xmit_active     (xmit_active)
    );
    u_rec u_rec_inst (
        .uart_clk        (uart_clk),
        .sys_rst_l       (sys_rst_l),
        .uart_REC_dataH  (uart_REC_dataH),
        .rec_dataH       (rec_dataH),
        .rec_readyH      (rec_readyH),
        .rec_busy        (rec_busy)
    );

endmodule

