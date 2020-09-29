//
// Module CatRecognizer2020_lib.mult
//
// Created:
//          by - eshelga.UNKNOWN (L118W111)
//          at - 20:46:33 12/26/2019
//
// Generated by Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//
`include "params.v"
`resetall
`timescale 1ns/10ps
module mult(
  input clk,  //clock
  input rst,  //reset
  input wire signed    [`PIXEL_PRECISION:0]                        single_pixel_data,//single_pixel_data
  input   wire signed  [`WEIGHT_BIAS_PRECISION:0]                  single_weight_data,  //single_weight_data
  output  reg signed   [`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1:0] mult_out  //multipication result
  );
  
  //-----------------------------------------------------------------
  // Clocked Block for multipication calculation
  //-----------------------------------------------------------------
  always @(
  posedge clk, 
  negedge rst
  )
  begin :current_state_proc
    if (!rst)
    mult_out <= 0;
    else
    mult_out <= single_pixel_data*single_weight_data;
  end
  
endmodule