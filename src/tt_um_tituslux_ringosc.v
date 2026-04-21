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

  // User Inputs
  wire en = ui_in[0];       // Enable signal for the ring oscillator
  wire ring_in = ui_in[1];  // External feedback input (jumper from uio[0])
  wire mode = ui_in[2];     // 0 = normal mode [23:16], 1=bytse-select mode ([7:0], [15:8], [23:16], [31:24])
  wire [1:0] byte_sel = ui_in[4:3]; // Select which byte of ro_latched to output when mode=1 (00=LSB, 01=Byte1, 10=Byte2, 11=MSB)

  // Internal nodes for the ring oscillator without internal feedback to prevent optimization
 (* keep *) wire n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21;

  // 5-stage inverter chain with enable control (oscilates when ring_out is fed externally back to ring_in)
  assign n1 = en ? ~ring_in : 1'b0;     // First inverter with enable control
  assign n2 = ~n1;                      // Second inverter
  assign n3 = ~n2;                      // Third inverter 
  assign n4 = ~n3;                      // Fourth inverter 
  assign n5 = ~n4;                      // Fifth inverter 
  assign n6 = ~n5;                      // Additional inverters to increase delay and reduce frequency
  assign n7 = ~n6;
  assign n8 = ~n7;
  assign n9 = ~n8;
  assign n10 = ~n9;
  assign n11 = ~n10;
  assign n12 = ~n11;
  assign n13 = ~n12;
  assign n14 = ~n13;
  assign n15 = ~n14;
  assign n16 = ~n15;
  assign n17 = ~n16;
  assign n18 = ~n17;
  assign n19 = ~n18;
  assign n20 = ~n19;
  assign n21 = ~n20;                    // Final inverter stage (total 21 stages for more delay)

reg ro_sync1, ro_sync2;     // Synchronization registers for the asynchronous ring oscillator
reg ro_sync2_d;    // Delayed version of ro_sync2 to detect edges

// Synchronize the ring oscillator output to the system clock domain
always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro_sync1 <= 1'b0;
        ro_sync2 <= 1'b0;
        ro_sync2_d <= 1'b0;
    end else begin
        ro_sync1 <= ring_out;   // First stage of synchronization
        ro_sync2 <= ro_sync1;   // Second stage of synchronization
        ro_sync2_d <= ro_sync2; // Delayed version of ro_sync2 for edge detection
    end
end

wire ro_edge = ro_sync2 ^ ro_sync2_d; // Detect edges of the ring oscillator output (rising and falling) 

reg [31:0] ro_count;    // Counter to measure the edges within window
reg [15:0] window_cnt;  // Counter to create a time window for counting edges (65536 cycles at 16 bits)
reg [31:0] ro_latched;  // Latches RO edge count from previous window

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ro_count    <= 32'd0;
        window_cnt  <= 16'd0;
        ro_latched  <= 32'd0;

    end else begin
        window_cnt <= window_cnt + 16'd1;     // Increment the window counter on each clock cycle

        if (ro_edge)
            ro_count <= ro_count + 32'd1;     // Increment the count on each edge

        if (window_cnt == 16'hFFFF) begin      
            ro_latched <= ro_count;           // Latch result value every 65536 clk cycles
            window_cnt <= 16'd0;              // Reset window counter
            ro_count <= 32'd0;                // Reset RO edge count
        end
    end
end

wire ring_out;       // Ring oscillator tap (connect to uio[0] to ui[1] to complete the loop)
assign ring_out = n21; // Output from the final inverter stage of the ring oscillator

// Output logic: Select which byte of the latched count to output based on mode and byte_sel
wire [7:0] demo_byte = ro_latched[23:16]; // Default midle stable byte for mode =0

reg [7:0] sel_byte;
always @(*) begin
    case (byte_sel)
        2'b00: sel_byte = ro_latched[7:0];     // Byte 0 (LSB)
        2'b01: sel_byte = ro_latched[15:8];    // Byte 1
        2'b10: sel_byte = ro_latched[23:16];   // Byte 2 (default stable byte)
        2'b11: sel_byte = ro_latched[31:24];   // Byte 3 (MSB)
        default: sel_byte = ro_latched[23:16]; // Default to byte 2
    endcase
end

// Drive Outputs based on mode selection
assign uo_out = mode ? sel_byte : demo_byte; // Output selected byte based on mode (mode=0 outputs stable middle byte, mode=1 outputs selected byte)

assign uio_out = {7'b0, ring_out};  // Drive ring oscillator tap to uio[0] for external feedback
assign uio_oe = 8'b0000_0001;       // Only uio[0] is output

// List all unused inputs to prevent warnings
wire _unused = &{ena, ui_in[7:5], uio_in};

endmodule
