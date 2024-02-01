`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2023 19:50:15
// Design Name: 
// Module Name: i2c_int
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// 100 MHz clock
// 
module i2c_int #(parameter int SPEED = 1000)(
    input logic clk_i,
    input logic rst_i,
    input logic i2c_req_i,
    input logic [6:0] addr_i,
    input logic [7:0] data_master_i,
    input logic [7:0] data_slave_i,
    
    input logic ackm_i,
    input logic acks_i,
    input logic rw_i,
    
    output logic scl_o,
    output logic sda_o
    );
       logic [6:0] addr_sr;
       logic [7:0] data_master_sr;
       logic [7:0] data_slave_sr;
       logic [3:0] counter;
       logic [63:0] clock_count;
       
       logic output_en;
       
       enum logic [3:0] { IDLE = 4'b0000,
                       START = 4'b0001,
                       ADDR = 4'b0010,
                       RW = 4'b0011,
                       ACKM = 4'b0100,
                       ACKSW = 4'b0101,
                       ACKSR = 4'b0110,
                       DATAW = 4'b0111,
                       DATAR = 4'b1000,
                       STOP = 4'b1001 } STATE;
     always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) scl_o <= 1;
        else begin
            if (output_en) begin
                if(clock_count == SPEED/4 | clock_count == 3*SPEED/4) scl_o <= ~scl_o;
            end
        end
     end
     always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            addr_sr <= 0;
            data_master_sr <= 0;
            data_slave_sr <= 0;
            STATE <= IDLE;
            clock_count <= 0;
            output_en <= 0;
        end else begin
            
            case (STATE)
            
                IDLE: begin
                    if (i2c_req_i) begin
                        STATE <= START;
                        output_en <= 1;
                        scl_o <= 0;
                    end
                end
                
                START: begin
                    if (clock_count == SPEED) begin
                        clock_count <= 0;
                        STATE <= ADDR;
                        addr_sr <= addr_i;
                        counter <= 0;
                    end 
                    
                    else clock_count <= clock_count + 1;
                end
                
                ADDR: begin
                    if (clock_count == SPEED) begin
                        clock_count <= 0;
                        if (counter == 6) begin
                            counter <= 0;
                            STATE <= RW;
                        end else begin
                            counter <= counter + 1;
                            addr_sr <= {addr_sr[5:0],1'b0};
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                RW: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (!rw_i) STATE <= ACKSW;
                        if (rw_i) STATE <= ACKSR;
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                ACKSW: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (acks_i) STATE <= STOP;
                        if (!acks_i) begin
                            STATE <= DATAW;
                            data_master_sr <= data_master_i;
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                DATAW: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (counter == 7) begin
                            counter <= 0;
                            STATE <= ACKSW;
                        end else begin
                            counter <= counter + 1;
                            data_master_sr <= {data_master_sr[6:0],1'b0};
                        end
                    end   
                    else clock_count <= clock_count + 1;    
                end
                
                ACKSR: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (acks_i) STATE <= STOP;
                        if (!acks_i) begin
                            STATE <= DATAR;
                            data_slave_sr <= data_slave_i;
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                DATAR: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (counter == 7) begin
                            counter <= 0;
                            STATE <= ACKM;
                        end else begin
                            counter <= counter + 1;
                            data_slave_sr <= {data_slave_sr[6:0],1'b0};
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                ACKM: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (ackm_i) STATE <= STOP;
                        if (!ackm_i) begin
                            STATE <= DATAR;
                            data_slave_sr <= data_slave_i;
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
                STOP: begin
                    if(clock_count == SPEED) begin
                        clock_count <= 0;
                        if (i2c_req_i) STATE <= START;
                        else begin 
                            STATE <= IDLE;
                            output_en <= 0;
                            scl_o <= 1;
                        end
                    end
                    else clock_count <= clock_count + 1;    
                end
                
            endcase
        end
     end
     
     always_comb begin
        if(STATE == IDLE) sda_o <= 1;
        if(STATE == START) sda_o <= 0;
        if(STATE == ADDR) sda_o <= addr_sr[6];
        if(STATE == RW) sda_o <= rw_i;
        if(STATE == ACKSW) sda_o <= acks_i;
        if(STATE == DATAW) sda_o <= data_master_sr[7];
        if(STATE == ACKSR) sda_o <= acks_i;
        if(STATE == DATAR) sda_o <= data_slave_sr[7];
        if(STATE == ACKM) sda_o <= ackm_i;
        if(STATE == STOP) sda_o <= 1;
     end
endmodule
