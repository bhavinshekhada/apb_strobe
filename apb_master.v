module apb_master(
input              pclk,
input              valid,      
input              ext_psel,   
input              ext_write,  
input [31:0]       ext_addr,    
input   wire       pready,     
input [31:0]       slv_prdata,
input [31:0]       slv_pwdata,  
input [1:0]        pstrobe,                             
output             psel,       
output             penable,  
output             pwrite,
output [31:0]      pwdataa, 
output [31:0]      prdata,     
output [31:0]      paddr,
output [1:0]            strobe,
output             master_ready
);

reg                r_penable=0;
reg [31:0]         r_prdata=0;
reg [31:0]          r_pwdataa;
reg [1:0]          r_ext_psel;
reg [31:0]         r_ext_addr= 0;
reg                r_ext_write;  
reg [1:0]          r_strobe;    
reg [1:0]          p_state=2'd0;
parameter          IDLE = 2'd0;
parameter          SETUP = 2'd1;
parameter          ACCESS = 2'd2;

always @(posedge pclk) begin
    case (p_state)
       IDLE :       begin              //Idle state where Penable = 0 and Psel = 0
                        r_penable <= 0;      // Set penable low in the IDLE state
                        r_ext_psel <= 3'd0;
                        p_state <= valid ? SETUP : IDLE; // Transition to SETUP if valid, otherwise stay in IDLE
                    end

      
      SETUP : begin
              r_penable <= 0;
              r_ext_psel <= ext_psel;
              r_ext_addr <= ext_addr;
              r_ext_write <= ext_write;  // Make sure r_ext_write is updated here
              p_state <= ACCESS;
            end

      ACCESS : begin          //Access state where the transfer is enabled
                      r_penable <= 1'b1;
                    if(r_ext_write == 1) begin   
                    r_strobe   <= pstrobe;
                    r_pwdataa <= slv_pwdata;
                    end
                    else if (r_ext_write==0)
                      begin
                        r_prdata <= slv_prdata;

                      end
                    if(pready) begin
                    p_state <= IDLE;
                    r_penable <= 1'b0;
                    end
                    else
                    p_state <=ACCESS;
                end
      default: p_state <= IDLE; 
    endcase
  end     
        
 assign penable = r_penable;
 assign psel = r_ext_psel;
 assign pwrite = r_ext_write;
 assign paddr = r_ext_addr;
 assign prdata = r_prdata;
 assign pwdataa= r_pwdataa;
 assign strobe = r_strobe;
 assign master_ready = pready;
endmodule
