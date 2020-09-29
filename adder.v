//
// Module CatRecognizer2020_lib.adder
//
// Created:
//          by - eshelga.UNKNOWN (L118W111)
//          at - 10:03:18 12/27/2019
//
// Generated by Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
`include "params.v"

//The module sums two multipication result - pixel data with weight
module adder  
(
  input clk,  //clock
  input rst,  //reset
  input wire signed   [`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1:0] a,  //the first input to add
  input wire signed   [`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1:0] b,  //the second input to add
  output reg signed  [`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1:0] sum,//the adding input result
  output reg                                                       c   //the carry
  //output wire                                                       c_sign
);

  reg signed [`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+2:0] result;          //the wire for the result

//assign  result = a+b;                                             //result include the carry

  always @(a,b)
  begin:async_adder_proc
     result = a+b;
  end

//-----------------------------------------------------------------
// Clocked Block for adding calculation
//-----------------------------------------------------------------
  always @(
  posedge clk, 
  negedge rst
  )
  begin :sync_adder_proc
    if (!rst)
    begin
      sum <= 0;
      c <= 0;
    end
    else
    begin
      sum <= result[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1:0];//result exclude the carry
      c <= (a[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1] ^       //this is the carry calculation for signed number   
            b[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1]) ?       //the lines are splited to avoid checker warnings
            0 : (a[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+1]) ?  //the lines are splited to avoid checker warnings
            !(result[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION] &&  //the lines are splited to avoid checker warnings
            result[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+2]) :  //the lines are splited to avoid checker warnings
            result[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION] ||    //the lines are splited to avoid checker warnings
            result[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION+2];    //the lines are splited to avoid checker warnings
    end
  end
endmodule
