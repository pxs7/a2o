// © IBM Corp. 2020
// Licensed under the Apache License, Version 2.0 (the "License"), as modified by
// the terms below; you may not use the files in this repository except in
// compliance with the License as modified.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Modified Terms:
//
//    1) For the purpose of the patent license granted to you in Section 3 of the
//    License, the "Work" hereby includes implementations of the work of authorship
//    in physical form.
//
//    2) Notwithstanding any terms to the contrary in the License, any licenses
//    necessary for implementation of the Work that are available from OpenPOWER
//    via the Power ISA End User License Agreement (EULA) are explicitly excluded
//    hereunder, and may be obtained from OpenPOWER under the terms and conditions
//    of the EULA.
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
// for the specific language governing permissions and limitations under the License.
//
// Additional rights, including the ability to physically implement a softcore that
// is compliant with the required sections of the Power ISA Specification, are
// available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
// obtained (along with the Power ISA) here: https://openpowerfoundation.org.

`timescale 1 ns / 1 ns

// *!****************************************************************
// *! FILENAME    : tri_inv_nlats.v
// *! DESCRIPTION : n-bit scannable m/s latch, for bit stacking, with inv gate in front
// *!****************************************************************

`include "tri_a2o.vh"

module tri_inv_nlats(
   vd,
   gd,
   clk,
   rst,
   d1clk,
   d2clk,
   scanin,
   scanout,
   d,
   qb
);
   parameter                      OFFSET = 0;
   parameter                      WIDTH = 1;
   parameter                      INIT = 0;
   parameter                      L2_LATCH_TYPE = 2;            //L2_LATCH_TYPE = slave_latch;
                                                                //0=master_latch,1=L1,2=slave_latch,3=L2,4=flush_latch,5=L4
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      BTR = "NLI0001_X1_A12TH";
   parameter                      NEEDS_SRESET = 1;		// for inferred latches
   parameter                      DOMAIN_CROSSING = 0;

   inout                          vd;
   inout                          gd;
   input                          clk;
   input                          rst;
   input                          d1clk;
   input                          d2clk;
   input [OFFSET:OFFSET+WIDTH-1]  scanin;
   output [OFFSET:OFFSET+WIDTH-1] scanout;
   input [OFFSET:OFFSET+WIDTH-1]  d;
   output [OFFSET:OFFSET+WIDTH-1] qb;

   // tri_inv_nlats

   parameter [0:WIDTH-1]          init_v = INIT;
   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};

   generate
   begin
      wire                          sreset;
      wire [0:WIDTH-1]              int_din;
      reg [0:WIDTH-1]               int_dout;
      wire [0:WIDTH-1]              vact;
      wire [0:WIDTH-1]              vact_b;
      wire [0:WIDTH-1]              vsreset;
      wire [0:WIDTH-1]              vsreset_b;
      wire [0:WIDTH-1]              vthold;
      wire [0:WIDTH-1]              vthold_b;
      wire [0:WIDTH-1]              din;
       (* analysis_not_referenced="true" *)
      wire                          unused;

      if (NEEDS_SRESET == 1) begin
        assign sreset = rst;
      end else begin
        assign sreset = 1'b0;
      end

      assign vsreset = {WIDTH{sreset}};
      assign vsreset_b = {WIDTH{~sreset}};
      assign din = d;		// Output is inverted, so don't invert here
      assign int_din = (vsreset_b & din) | (vsreset & init_v);

      assign vact = {WIDTH{d1clk}};
      assign vact_b = {WIDTH{~d1clk}};

      assign vthold_b = {WIDTH{d2clk}};
      assign vthold = {WIDTH{~d2clk}};

      always @(posedge clk) begin: l
        //int_dout <= (((vact & vthold_b) | vsreset) & int_din) | (((vact_b | vthold) & vsreset_b) & int_dout);
        if (sreset)
          int_dout <= int_din;
        else if (d1clk & d2clk)
          int_dout <= int_din;
      end

      assign qb = (~int_dout);
      assign scanout = ZEROS;

      assign unused = | {vd, gd, scanin};
   end
   endgenerate
endmodule
