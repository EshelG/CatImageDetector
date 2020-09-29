//
// Include file CatRecognizer2020_lib
//
// Created:
//          by - eshelga.UNKNOWN (L118W111)
//          at - 10:59:55 01/12/2020
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`define AMBA_WORD     32
`define WEIGHT_BIAS_PRECISION 8
`define PIXEL_PRECISION 8
//`define NUMBER_OF_PIXELS 12287
`define NUMBER_OF_PIXELS 8
`define AMBA_ADDR_DEPTH 14
`define TWENTYFIVE_BITS_ONE 25'h1
`define PIXEL_PRECISION_PLUS_WEIGHT_BIAS_PRECISION 16
`define TWENTYFOUR_BITS_ONE 24'h1
`define ONE_bit 1
`define mac_delay $clog2(`NUMBER_OF_PIXELS)
`define count_delay_size 4