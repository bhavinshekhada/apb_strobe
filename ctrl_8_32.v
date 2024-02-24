module ctrl_8_32 (
    input         i_Clock,
    input         i_Rx_DV,
    input  [7:0]  i_Rx_Byte,
    output reg    o_Done=0,
    output reg [31:0] o_Output
);


reg [31:0] temp_reg = 32'd0;
reg [3:0]  byte_count = 4'd0;
reg [1:0]  state = 2'd0;

parameter IDLE = 2'd0;
parameter ACCUMULATE = 2'd1;
parameter DONE = 2'd2;

always @(posedge i_Clock) begin
    case (state)
        IDLE: 
         begin 
            if (i_Rx_DV) begin
           temp_reg[7:0] <=  i_Rx_Byte ;
               state <= ACCUMULATE; 
            end
        end
        ACCUMULATE:
            begin 
                if (byte_count == 3 ) begin
                    o_Output <= temp_reg;
                    temp_reg <= 32'd0;
                    byte_count <= 4'd0;
                    o_Done <= 1'b1;
                    state <= DONE;
                end else if (i_Rx_DV)
              
               begin
                     byte_count <= byte_count + 1;
                    temp_reg <= {temp_reg[23:0], i_Rx_Byte} ;
                   
                end
            end

        DONE:
         begin 
            if (!i_Rx_DV) begin
                o_Done <= 1'b0;
                state <= IDLE; // Go back to IDLE state
            end
        end
    endcase
end

endmodule