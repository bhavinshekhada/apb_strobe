module top(
    input           clock_r,
    input           clock_w,
    input           reset,
    input           i_Rx_Serial,
    input           sel,
    input           write,
    output         o_Tx_Active,
    output          o_Tx_Serial,
    output         o_Tx_Done
   
);

    // Internal signals
    wire c;
    wire [7:0] b;
    wire a;
    wire [31:0]d;
    wire full;
    wire empty;
    wire full2;
    wire empty2;
    wire [31:0] data_count_w;
    wire [31:0] data_count_r;
    wire e;
    wire aa;
    wire [31:0] f;
    wire [7:0]  mm;
    wire zz;
    wire xx;
    wire xx2;
    wire p;
    wire p2;
    
    wire[1:0] d3;
    wire d4;
    wire [31:0] i;
    wire [31:0] i2;
    wire [31:0] ii;
    wire [31:0] jj;
    wire aaa;
    wire bb;
    wire [31:0] dd;
    wire [31:0] ee;
    wire [31:0] d2;
    wire mm;
    wire d5;
    
    
uart_rx  #(.CLKS_PER_BIT(87)) uartrx_1  (
        .i_Clock(clock_w),
        .i_Rx_Serial(i_Rx_Serial),
        .o_Rx_DV(a),  // Connect to FIFO write enable
        .o_Rx_Byte(b)
    );

ctrl_8_32  ctrl1 (
        .i_Clock(clock_w),
        .i_Rx_DV(a),
        .i_Rx_Byte(b),
        .o_Done(aa),
        .o_Output(f));
              
fifo  #(
     .DWIDTH (32),
     .ADEPTH (5)) fifo_1(

        . CLK(clock_w),
        . RST(reset),
        
        . WR_EN(aa),
        . DIN(f),
        . FULL(full),
        
        . RD_EN(xx),
        . DOUT(d),
        . EMPTY(empty));
 
ctrl2   ctrl2_dut(
        .clk(clock_w),
        .rst_n(reset),
        .empty(empty),
        .data_read(d), 
        .read(xx)
        );

apb_master apb_master1(
        .pclk(clock_w),
        .valid(xx),
        .ext_psel(sel),
        .ext_write(write),
        .ext_addr(32'h12345566),
        .pready(p),
        .slv_prdata(),
        .slv_pwdata(d),
        .pstrobe(2'b11),
        .psel(aaa),
        .penable(bb),
        .pwrite(),
        .pwdataa(ee),//write
        .prdata(),//read
        .paddr(dd),
        .strobe(d3)
);

apb_slave apb_slave1 (
        .pclk(clock_w),
        .preset_n(reset),
        .psel(aaa),
        .penable(bb),
        .pwrite(write),
        .paddr(dd),
        .pwdata(ee),
        .p_strobe(d3),
        .u_busy(d4),
        .pwdata_out(ii),
        .prdata_out(), 
        .dv(p2),
        .pready(p)
    );
       
ctrl_uart   ctrluart(
        . clk(clock_w),
        . s_strobe(d3),
        . data_write(ii),
        . enable(1),
        . done(o_Tx_Done),
        . busy(d4),
        . dv(d5),
        . tx_data(mm));
       
   

uart_tx #(.CLKS_PER_BIT(87))uarttx_1 (
        . i_Clock(clock_w),
        . i_Tx_DV(d5),
        . i_Tx_Byte(mm), 
        . o_Tx_Active(o_Tx_Active),
        . o_Tx_Serial(o_Tx_Serial),
        . o_Tx_Done(o_Tx_Done));

endmodule

    