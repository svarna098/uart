
/*module uart_rx_ref #(parameter width = 8)(
    input                   sys_rst,
    input                   baud_op_clk,
    input                   uart_rec_data_h,
    output reg              rec_busy,
    output reg              rec_ready,
    output reg [width-1:0]  rec_data_h,
    output reg [width-1:0]  shift_out,
    output reg [3:0]        bit_index
);
    integer i;
    reg [width-1:0] shift;
    reg             rx2_sampled;

    initial begin
        rec_busy    = 0;
        rec_ready   = 0;
        rec_data_h  = 0;
        shift_out   = 0;
        bit_index   = 0;
        shift       = 0;
        rx2_sampled = 1;
    end

    always @(negedge uart_rec_data_h or negedge sys_rst) begin : rx_frame
        if (!sys_rst) begin
            rec_busy    = 0;
            rec_ready   = 0;
            rec_data_h  = 0;
            shift_out   = 0;
            bit_index   = 0;
            shift       = 0;
        end
        else begin
            rec_busy   = 1;
            rec_ready  = 0;
            shift      = 0;        // clear shift at start of every frame
            rec_data_h = 0;        // clear output too

            // Wait to mid-point of start bit and verify still low
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b0) begin
                rec_busy = 0;
                disable rx_frame;
            end

            // Wait out remainder of start bit
            repeat(8) @(posedge baud_op_clk);

            // Sample each data bit - MSB-first RIGHT SHIFT to match design
            // Design uses: rec_data_h <= {rx2_sampled, rec_data_h[width-1:1]}
            for (i = 0; i < width; i = i + 1) begin
                repeat(8) @(posedge baud_op_clk);
                rx2_sampled = uart_rec_data_h;
                // mirror design: new bit enters at MSB, rest shifts right
                shift      = {rx2_sampled, shift[width-1:1]};
                rec_data_h = shift;
                shift_out  = shift;
                bit_index  = i;
                repeat(8) @(posedge baud_op_clk);
            end

            // Check stop bit at mid-point
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b1) begin
                $display("[uart_rx_ref] FRAMING ERROR at time %0t", $time);
                rec_data_h = 0;
            end
            else begin
                rec_data_h = shift;
                rec_ready  = 1;
            end

            // Wait out rest of stop bit
            repeat(8) @(posedge baud_op_clk);
            rec_busy  = 0;
            rec_ready = 0;
            bit_index = 0;
        end
    end

endmodule*/
// ============================================================
//  uart_rx_ref  behavioral reference RX
//  FIX 1: rec_ready asserts AFTER rec_busy clears (not during)
//  FIX 2: rec_ready held high for 1 full baud tick then clears,
//          matching DUT single-tick pulse behaviour
// ============================================================
/*
module uart_rx_ref #(parameter width = 8)(
    input                   sys_rst,
    input                   baud_op_clk,
    input                   uart_rec_data_h,
    output reg              rec_busy,
    output reg              rec_ready,
    output reg [width-1:0]  rec_data_h,
    output reg [width-1:0]  shift_out,
    output reg [3:0]        bit_index
);
    integer i;
    reg [width-1:0] shift;
    reg             rx2_sampled;

    initial begin
        rec_busy    = 0;
        rec_ready   = 0;
        rec_data_h  = 0;
        shift_out   = 0;
        bit_index   = 0;
        shift       = 0;
        rx2_sampled = 1;
    end

    always @(negedge uart_rec_data_h or negedge sys_rst) begin : rx_frame
        if (!sys_rst) begin
            rec_busy   = 0;
            rec_ready  = 0;
            rec_data_h = 0;
            shift_out  = 0;
            bit_index  = 0;
            shift      = 0;
        end
        else begin
            rec_busy  = 1;
            rec_ready = 0;
            shift     = 0;
            rec_data_h = 0;

            // Mid-point of start bit  verify still low
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b0) begin
                rec_busy = 0;
                disable rx_frame;
            end

            // Wait out remainder of start bit
            repeat(8) @(posedge baud_op_clk);

            // Sample each data bit at mid-bit, mirror DUT right-shift
            for (i = 0; i < width; i = i + 1) begin
                repeat(8) @(posedge baud_op_clk);
                rx2_sampled = uart_rec_data_h;
                shift       = {rx2_sampled, shift[width-1:1]};
                rec_data_h  = shift;
                shift_out   = shift;
                bit_index   = i;
                repeat(8) @(posedge baud_op_clk);
            end

            // Check stop bit at mid-point
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b1) begin
                $display("[uart_rx_ref] FRAMING ERROR at time %0t", $time);
                rec_data_h = 0;
                // Wait out rest of stop bit then clear busy
                repeat(8) @(posedge baud_op_clk);
                rec_busy  = 0;
                rec_ready = 0;
                bit_index = 0;
                disable rx_frame;
            end

            // Valid stop bit:
            // FIX: clear busy FIRST, then assert ready
            // This matches DUT where ready pulses after busy drops
            repeat(8) @(posedge baud_op_clk);  // wait out rest of stop bit
            rec_busy  = 0;                      // busy clears first

            // Now pulse ready for exactly 1 baud tick
            rec_ready = 1;
            @(posedge baud_op_clk);
            rec_ready = 0;
            bit_index = 0;
        end
    end

endmodule  */

module uart_rx_ref #(parameter width = 8)(
    input                   sys_rst,
    input                   baud_op_clk,
    input                   uart_rec_data_h,
    output reg              rec_busy,
    output reg              rec_ready,
    output reg [width-1:0]  rec_data_h,
    output reg [width-1:0]  shift_out,
    output reg [3:0]        bit_index
);
    integer i;
    reg [width-1:0] shift;
    reg             rx2_sampled;

    initial begin
        rec_busy    = 0;
        rec_ready   = 1;   // idle: ready HIGH, busy LOW
        rec_data_h  = 0;
        shift_out   = 0;
        bit_index   = 0;
        shift       = 0;
        rx2_sampled = 1;
    end

    always @(negedge uart_rec_data_h or negedge sys_rst) begin : rx_frame
        if (!sys_rst) begin
            rec_busy   <= 0;
            rec_ready  <= 1;   // after reset: idle state = ready HIGH
            rec_data_h <= 0;
            shift_out  <= 0;
            bit_index  <= 0;
            shift      <= 0;
        end
        else begin
            // Frame starting  busy HIGH, ready LOW
            rec_busy  <= 1;
            rec_ready <= 0;   // busy=1 so ready=0
            shift     <= 0;
            rec_data_h <= 0;

            // Mid-point of start bit  verify still low
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b0) begin
                // False start  go idle: busy=0, ready=1
                rec_busy  = 0;
                rec_ready = 1;
                disable rx_frame;
            end

            // Wait out remainder of start bit
            repeat(8) @(posedge baud_op_clk);

            // Sample each data bit at mid-bit  busy=1, ready=0 throughout
            for (i = 0; i < width; i = i + 1) begin
                repeat(8) @(posedge baud_op_clk);
                rx2_sampled = uart_rec_data_h;
                shift       = {rx2_sampled, shift[width-1:1]};
                rec_data_h  = shift;
                shift_out   = shift;
                bit_index   = i;
                repeat(8) @(posedge baud_op_clk);
            end

            // Check stop bit at mid-point
            repeat(8) @(posedge baud_op_clk);
            if (uart_rec_data_h !== 1'b1) begin
                $display("[uart_rx_ref] FRAMING ERROR at time %0t", $time);
                rec_data_h = 0;
                repeat(8) @(posedge baud_op_clk);
                // Framing error  go idle: busy=0, ready=1
                rec_busy  = 0;
                rec_ready = 1;
                bit_index = 0;
                disable rx_frame;
            end

            // Valid stop bit received
            // Wait out rest of stop bit  still busy=1, ready=0
            repeat(8) @(posedge baud_op_clk);

            // Now frame complete:
            // busy clears FIRST, then ready goes HIGH and stays HIGH
            // ready stays HIGH until next frame starts (next negedge)
            rec_busy  = 0;
            rec_ready = 1;   // ready=HIGH, stays high until next start bit
            bit_index = 0;
        end
    end
endmodule
