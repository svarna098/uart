/*module uart_tx #(parameter width = 8)(
    input                   baud_op_clk,
    input                   sys_rst,
    input                   xmit_h,
    input  [width-1:0]      xmit_data_h,
    output reg              xmit_done_h,
    output reg              xmit_active,
    output reg              uart_xmit_data_h
);
    localparam idle  = 2'd0,
               start = 2'd1,
               data  = 2'd2,
               stop  = 2'd3;
 
    reg [1:0]             ct, nt;
    reg [3:0]             count;
    reg [$clog2(width):0] index;
    reg [width-1:0]       latched_data;
    reg                   out;
 
    always @(posedge baud_op_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            ct               <= idle;
            count            <= 0;
            index            <= 0;
            latched_data     <= 0;
            uart_xmit_data_h <= 1;
            xmit_done_h      <= 1;
            xmit_active      <= 0;
        end
        else begin
            ct               <= nt;
            uart_xmit_data_h <= out;
 
            if (xmit_h && ct == idle)
                latched_data <= xmit_data_h;
 
            if (ct == idle)       count <= 0;
            else if (nt != ct)    count <= 0;
            else                  count <= count + 1;
 
            if (ct == idle)       index <= 0;
            else if (ct == data && count == 15 && nt == data)
                                  index <= index + 1;
 
            
            if (ct == stop && nt == idle)
                xmit_done_h <= 1'b1;
            else if (ct == idle && xmit_h)
                xmit_done_h <= 1'b0;
 
            xmit_active <= (nt != idle);
        end
    end
 
    always @(*) begin
        nt  = ct;
        out = 1;
        case (ct)
            idle:  begin out = 1; nt = xmit_h ? start : idle; end
            start: begin out = 0; nt = (count == 15) ? data  : start; end
            data:  begin
                out = latched_data[index];
                if (count == 15)
                    nt = (index == width - 1) ? stop : data;
                else
                    nt = data;
            end
            stop:  begin out = 1; nt = (count == 15) ? idle : stop; end
            default: begin out = 1; nt = idle; end
        endcase
    end
endmodule
*/
module uart_tx #(parameter width = 8)(
    input                  baud_op_clk,
    input                  sys_rst,
    input                  xmit_h,
    input  [width-1:0]     xmit_data_h,
    output                 xmit_done_h,
    output                 xmit_active,
    output                 uart_xmit_data_h
);
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0]             ct;
    reg [3:0]             count;
    reg [$clog2(width):0] index;
    reg [width-1:0]       latched_data;

    // ---------------------------------------------------------------
    // Combinational outputs
    // ---------------------------------------------------------------
    assign xmit_active      = (ct != IDLE) || (ct == IDLE && xmit_h);
    assign xmit_done_h      = (ct == IDLE) && !xmit_h;
    assign uart_xmit_data_h = (ct == IDLE  && !xmit_h) ? 1'b1                :
                               (ct == IDLE  &&  xmit_h) ? 1'b0                :
                               (ct == START            ) ? 1'b0                :
                               (ct == DATA             ) ? latched_data[index] :
                               (ct == STOP             ) ? 1'b1                :
                                                           1'b1                ;

    // ---------------------------------------------------------------
    // Sequential block
    //
    // count free-runs 0->15->0->15 continuously once started
    // state transitions ONLY happen at count==15
    // so every state gets exactly 16 cycles (count 0,1,...,15)
    //
    // IDLE->START: count is forced to 0 on the transition edge
    //              so START sees count 0,1,...,15 = 16 cycles
    // All other transitions happen at count==15 naturally
    //              next state entry always at count==0 (next cycle)
    // ---------------------------------------------------------------
    always @(posedge baud_op_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            ct           <= IDLE;
            count        <= 4'd0;
            index        <= 0;
            latched_data <= 0;
        end
        else begin
            case (ct)

                IDLE: begin
                    index <= 0;
                    if (xmit_h) begin
                        latched_data <= xmit_data_h;
                        ct           <= START;
                        count        <= 4'd0;
                        // START will see count=0,1,...,15 = 16 cycles
                    end else begin
                        count <= 4'd0;
                    end
                end

                START: begin
                    count <= count + 1'b1;
                    if (count == 4'd15) begin
                        ct    <= DATA;
                        // count naturally rolls to 0 next cycle
                        // DATA entry sees count=0
                    end
                end

                DATA: begin
                    count <= count + 1'b1;
                    if (count == 4'd15) begin
                        if (index == width - 1) begin
                            index <= 0;
                            ct    <= STOP;
                        end else begin
                            index <= index + 1'b1;
                            ct    <= DATA;
                        end
                        // count naturally rolls to 0 next cycle
                    end
                end

                STOP: begin
                    count <= count + 1'b1;
                    if (count == 4'd15) begin
                        ct    <= IDLE;
                        count <= 4'd0;
                    end
                end

                default: begin
                    ct    <= IDLE;
                    count <= 4'd0;
                    index <= 0;
                end

            endcase
        end
    end

endmodule
