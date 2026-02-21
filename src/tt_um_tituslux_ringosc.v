/*
 * Copyright (c) 2026 Titus Lux
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tituslux_ringosc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  wire en = ui_in[0]; // Use the first bit of ui_in as an enable signal for the ring oscillator
  wire ring_in = ui_in[1]; // External feedback input
  
 (* keep *) wire n1, n2, n3, n4, n5; // Internal nodes for the ring oscillator without internal feedback to prevent optimization

  // 5 - stage ring oscillator with enable control
  assign n1 = en ? ~ring_in : 1'b0;  // First inverter with enable control
  assign n2 = ~n1;              // Second inverter
  assign n3 = ~n2;              // Third inverter 
  assign n4 = ~n3;              // Fourth inverter 
  assign n5 = ~n4;              // Fifth inverter 

wire ring_out = n5;
reg ro_sync1, ro_sync2;

// Synchronize the ring oscillator output to the system clock domain
always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro_sync1 <= 1'b0;
        ro_sync2 <= 1'b0;
    end else begin
        ro_sync1 <= ring_out;       // First stage of synchronization
        ro_sync2 <= ro_sync1; // Second stage of synchronization
    end
end

wire ro_edge = ro_sync1 ^ ro_sync2; // Detect edges of the ring oscillator output (rising and falling) 

reg [15:0] ro_count;    // Counter to measure the edges of the ring oscillator
reg [15:0] window_cnt;  // Counter to create a time window for counting edges
reg [15:0] ro_latched;  // Register to latch the count value

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro_count    <= 16'd0;
        window_cnt  <= 16'd0;
        ro_latched  <= 16'd0;

    end else begin
        window_cnt <= window_cnt + 16'd1; // Increment the window counter on each clock cycle

        if (ro_edge)
            ro_count <= ro_count + 16'd1;     // Increment the count on each edge

        if (window_cnt == 16'hFFFF) begin
            ro_latched <= ro_count;       // Latch the count value after 65536 windows
            window_cnt <= 16'd0;              // Reset the window counter
            ro_count <= 16'd0;                // Reset ring oscillator count
        end
    end
end

assign uo_out = ro_latched[7:0];   // 8 bit latches edge count (LSBs)

assign uio_out = {7'b0, ring_out}; // 
assign uio_oe = 8'b0000_0001;  // only uio[0] is output

// List all unused inputs to prevent warnings
wire _unused = &{ena, ui_in[7:2], uio_in};

endmodule
