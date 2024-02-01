`timescale 1ns / 1ps

module tb_i2c();

    reg clk;
    reg rst;
    reg req;
    reg [6:0] addr;
    reg [7:0] master_data;
    reg [7:0] slave_data;
    reg ackm;
    reg acks;
    reg rw;
    reg SDA;
    reg SCL;
    
    i2c_int i2c(
        .clk_i(clk),
        .rst_i(rst),
        .i2c_req_i(req),
        .addr_i(addr),
        .data_master_i(master_data),
        .data_slave_i(slave_data),
    
        .ackm_i(ackm),
        .acks_i(acks),
        .rw_i(rw),
    
        .sda_o(SDA),
        .scl_o (SCL)
    );
     
    initial clk = 0;
    always #10 clk = ~clk;
    initial begin
        $display( "\nStart test: \n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
        rst = 1;
        req = 1;
        addr = 7'b0100111;
        ackm = 0;
        acks = 0;
        rw = 0;
        slave_data = 8'b01011010;
        master_data = 8'b00000001;// screen clear
        #60000;
        rst = 0;
        #20
        req = 0;
        #360000
        master_data = 8'b00000111; //set byte shift
        #180000
        master_data = 8'b00110100; //set line 1 and font
        #180000
        master_data = 8'b01000110; //F
         #180000
        master_data = 8'b01001001; // I
        #180000
        master_data = 8'b01000110; // F
         #180000
        master_data = 8'b01001111; // O
         #180000
        master_data = 8'b01011111; // _
         #180000
        master_data = 8'b01010010;// R
         #180000
        master_data = 8'b01011111; // _
         #180000
        master_data = 8'b01010111; // W
         #180000
        master_data = 8'b00100000; // space
         #180000
        master_data = 8'b01000001; // A
         #180000
        master_data = 8'b01000100; // D
         #180000
        master_data = 8'b01000100; // D
         #180000
        master_data = 8'b01010010;// R
         #180000
        master_data = 8'b01011111;// _
         #180000
        master_data = 8'b00110110;// 6
         #180000
        master_data = 8'b00111000;// 8
         #180000
        acks = 1;
        #360000
        
        req = 1;
        addr = 7'b1101000;
        ackm = 0;
        acks = 0;
        rw = 1;
        slave_data = 8'b01110111;
        #20
        req = 0;
        #340000
        ackm = 1;
        #400000
        ackm = 0;
        req = 1;
        addr = 7'b1110100;
        acks = 0;
        rw = 0;
        master_data = 8'b00110100;// line2
        #20000
        req = 0;
        #340000
        master_data = 8'b00100000; // space1
        #180000
        master_data = 8'b00100000; // space2
        #180000
        master_data = 8'b00100000; // space3
        #180000
        master_data = 8'b00100000; // space4
        #180000
        master_data = 8'b00100000; // space5
        #180000
        master_data = 8'b00100000; // space6
        #180000
        master_data = 8'b00100000; // space7
        #180000
        master_data = 8'b00100000; // space8
        #180000
        master_data = 8'b01110111; // space8
        #180000
        acks = 1;
        ackm = 1;
        #50000
        $display("\n The test is over \n See the internal signals of the module on the waveform \n");
        $finish;
    end
endmodule

