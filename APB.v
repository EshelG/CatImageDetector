//
// Module CatRecognizer2020_lib.APB
//
// Created:
//          by - eshelga.UNKNOWN (L118W111)
//          at - 21:26:46 12/26/2019
//
// Generated by Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//
`include "params.v"
`resetall
`timescale 1ns/10ps
module APB( 
  // Port Declarations
  input   wire                                                     clk,         // APB
  input   wire    [`AMBA_ADDR_DEPTH-1:0]                           paddr,       // APB
  input   wire                                                     penable,     // APB
  input   wire                                                     psel,        // APB
  input   wire    [`AMBA_WORD-1:0]                                 pwdata,      // APB
  input   wire                                                     pwrite,      // APB
  input   wire                                                     calc_done,   // APB
  input   wire                                                     rst,         // APB
  output  reg     [`WEIGHT_BIAS_PRECISION-`ONE_bit:0]              bias,        // APB
  output  reg     [`PIXEL_PRECISION*`NUMBER_OF_PIXELS-`ONE_bit:0]  pixdata,     // APB
  output  reg     [`AMBA_WORD-1:0]                                 prdata,      // APB
  output  reg                                                      pready,      // APB
  output  reg                                                      start_work,  // APB
  output  reg     [`WEIGHT_BIAS_PRECISION*`NUMBER_OF_PIXELS-`ONE_bit:0]   weights      // APB
  );
  `include "APB_parameters.v"
  // Internal Declarations
  // Internal Declarations
  // Internal Declarations
  reg [`PIXEL_PRECISION-1:0] X_Register_bank [`NUMBER_OF_PIXELS:0]; // pixel data register bank declaration
  reg [`WEIGHT_BIAS_PRECISION-1:0] W_Register_bank [`NUMBER_OF_PIXELS:0]; // weights register bank declaration
  reg [`WEIGHT_BIAS_PRECISION-1:0] B_Register;
  // reg [`ONE_bit:0] prev_state;// state declaration
  reg [`ONE_bit:0] current_state;// state declaration
  reg [`ONE_bit:0] next_state; // state declaration
  
  reg [`AMBA_ADDR_DEPTH-1:0]async_addr; // for async always use
  reg [`AMBA_WORD-1:0] async_wdata;     // for async always use
  reg async_write;                      // for async always use
  reg async_read;                       // for async always use
  reg next_pready;                      // for async always use
  reg next_start_work;                  // for async always use
  
  reg [`AMBA_ADDR_DEPTH-1:0]addr;       //synchronized address
  reg [`AMBA_WORD-1:0] wdata;           //synchronized data
  reg write;                            //synchronized  write order
  reg read;                             //synchronized read order
  reg calc_flag;                        //1 when start calculating but the start work haven't rised yet and 0 otherwise
  
  integer i;//for loop
  
  
  
  // State encoding
  /*parameter 
  IDLE   = 2'd0, // state0
  SETUP  = 2'd1, // state1
  ACCES = 2'd2,  // state2
  RESET = 2'd3;  // state3 - dummy state
 */ 
  
  
  //-----------------------------------------------------------------
  // Next State Block for machine fsm
  //-----------------------------------------------------------------
  always @(
  current_state, 
  penable, 
  psel
  )
  begin : next_state_block_proc
    // Default Assignment
    // Default state assignment
    //next_state = current_state;
    case (current_state) 
      IDLE: begin
        if (psel == 1 & penable ==0)
        begin
          next_state = SETUP;
        end
        else
        next_state = IDLE;
      end
      SETUP: begin
        if (psel == 1 & penable == 1)
        begin
          next_state = ACCES;
        end
        else
        next_state = SETUP;
      end
      ACCES: begin
        if (penable == 0 & psel == 0)
        begin
          next_state = IDLE;
        end
        else if (psel == 1 & penable == 0)
        begin
          next_state = SETUP;
        end
        else
        next_state = ACCES;
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end // Next State Block
  
  //-----------------------------------------------------------------
  //Combinatorical process to assrt write or read
  //-----------------------------------------------------------------
  
  always @(*)
  begin :name_of_module_proc
    if (1)
    begin
      async_addr = paddr;
      async_wdata = pwdata;
      if (~next_start_work & ~calc_flag & next_state == SETUP & addr <= `NUMBER_OF_PIXELS + 1)
      begin
        next_pready = 1;
      end
      else
      begin
        next_pready = 0;
      end

      if(pready & ((current_state == SETUP) | (current_state == ACCES & next_state == ACCES)))
      begin
        if (pwrite)
        begin
          async_write = 1;
          async_read = 0;
        end
        else
        begin
          async_read = 1;
          async_write = 0;
        end
      end
      else
      begin
        async_write = 0;
        async_read = 0;
      end
      if(X_Register_bank[0] == 0) // only if start_work equal to zero assert pready
      begin
        next_start_work = 0;
      end
      else
      begin
        next_start_work = 1 ; 
      end
    end
  end
  
  //-----------------------------------------------------------------
  // Clocked Block for machine fsm
  //-----------------------------------------------------------------
  always @(
  posedge clk, 
  negedge rst
  )
  begin :current_state_proc
    if (!rst)
    //   begin
    current_state <= RESET;
    //  prev_state <= RESET;
    //  end
    else
    // begin
    current_state <= next_state;
    //    prev_state <= current_state;
    //  end
  end
  
  //-----------------------------------------------------------------
  //  syncroniuse process to manage the memory
  //-----------------------------------------------------------------
  always @(
  posedge clk, 
  negedge rst
  )
  begin : next_transfer_block_proc
    if (!rst) //initialize the registers 
    begin
      for (i=0;i<=`NUMBER_OF_PIXELS;i=i+1)  //register bank
      begin:reset
        X_Register_bank[i] <= `PIXEL_PRECISION'b0;
        W_Register_bank[i] <= `PIXEL_PRECISION'b0;
      end
      B_Register <=0;
      prdata <=0;
      pready <= 0;
      start_work <=0;
      write <= 0;
      read <= 0;
      addr <= 0;
      wdata <= 0;
      pixdata <= 0;
      weights <= 0;
      bias <= 0;
      calc_flag <= 0;
    end
    else
    begin
      start_work <= next_start_work;
      write <= async_write;
      read <= async_read;
      addr <= async_addr;
      wdata <= async_wdata;

      if(read)  //read actions
      begin
        pready <= next_pready;
        if(addr != 0 & addr < `NUMBER_OF_PIXELS)          //reading two pixels and two weights
        begin 
          prdata[`PIXEL_PRECISION-1-:`PIXEL_PRECISION] <= X_Register_bank [addr];
          prdata[`AMBA_WORD-1-`WEIGHT_BIAS_PRECISION-:`WEIGHT_BIAS_PRECISION] <= W_Register_bank [addr];  
          prdata[`PIXEL_PRECISION*2-1-:`PIXEL_PRECISION] <= X_Register_bank [addr+1];
          prdata[`AMBA_WORD-1-:`WEIGHT_BIAS_PRECISION] <= W_Register_bank [addr+1];
        end
        else if (addr == `NUMBER_OF_PIXELS)               //reading one pixel one weight and the bias
        begin
          prdata[`PIXEL_PRECISION-1-:`PIXEL_PRECISION] <= X_Register_bank [addr];
          prdata[`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION-1-:`WEIGHT_BIAS_PRECISION] <= W_Register_bank [addr];
          prdata[`AMBA_WORD-1:`PIXEL_PRECISION+`WEIGHT_BIAS_PRECISION] <= {{(`AMBA_WORD-`PIXEL_PRECISION-`WEIGHT_BIAS_PRECISION*2){1'b0}},B_Register};
        end
        else if (addr == `NUMBER_OF_PIXELS + 1)           //reading the bias only
        begin
          prdata <= {{(`AMBA_WORD-`WEIGHT_BIAS_PRECISION){1'b0}},B_Register};
        end
        else                                              //illegal address
        begin
          prdata <= 0;
        end
      end
      else if(write)  //write actions
      begin
        pready <= next_pready;
        if(addr != 0 & addr < `NUMBER_OF_PIXELS)
        begin
          X_Register_bank [addr] <= wdata[`PIXEL_PRECISION-1-:`PIXEL_PRECISION]; // write pixel data to register bank
          X_Register_bank [addr+1] <= wdata[`PIXEL_PRECISION*2-1-:`PIXEL_PRECISION];
          W_Register_bank [addr] <= wdata[`AMBA_WORD-1-`WEIGHT_BIAS_PRECISION-:`WEIGHT_BIAS_PRECISION];
          W_Register_bank [addr+1] <= wdata[`AMBA_WORD-1-:`WEIGHT_BIAS_PRECISION];
        end
        else if(addr != 0 & addr == `NUMBER_OF_PIXELS)
        begin
          X_Register_bank [addr] <= wdata[`PIXEL_PRECISION-1-:`PIXEL_PRECISION]; // write pixel data to register bank
          W_Register_bank [addr] <= wdata[`AMBA_WORD-1-`WEIGHT_BIAS_PRECISION-:`WEIGHT_BIAS_PRECISION];
          B_Register <= wdata[`WEIGHT_BIAS_PRECISION-1:0];
          X_Register_bank [0] <= 1;   //finished to write the bank - start work
        end
        
        else
        begin
          B_Register <= wdata[`WEIGHT_BIAS_PRECISION-1:0];
          X_Register_bank [0] <= 1;   //finished to write the bank - start work
        end
      end
      else if (calc_done)  //if the cat calculation done
      begin
        X_Register_bank [0] <= 0;
        pready <= 1;
      end
      else if(~next_start_work & async_write & addr > `NUMBER_OF_PIXELS-1)
      begin
        calc_flag <=1;
        pready <= next_pready;
      end
      else
      begin
        calc_flag <= 0;
        pready <= next_pready;
      end
      
      if (start_work == 0 && next_start_work == 1)  //start work
      begin
        bias <= B_Register;
        for(i=1;i<=`NUMBER_OF_PIXELS;i=i+1)
        begin:reg_assign
          pixdata[i*`PIXEL_PRECISION-1-:`PIXEL_PRECISION] <= X_Register_bank[i];
          weights[i*`WEIGHT_BIAS_PRECISION-1-:`WEIGHT_BIAS_PRECISION] <= W_Register_bank[i];
        end
      end
    end
    

  end
endmodule // APB