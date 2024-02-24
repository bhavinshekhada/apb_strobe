module ctrl_uart(
    input                   clk,
    input [1:0]             s_strobe,
    input  wire [31:0]      data_write,
    input                   enable,
    input                   done, // Signal indicating UART is ready for next byte

    output    reg            busy,
    output  reg              dv, // Data valid signal
    output reg [7:0]         tx_data
);

reg [1:0] max_counter;
reg [2:0] state;
parameter idle = 3'b000;
parameter byte1 = 3'b001;
parameter byte2 = 3'b010;
parameter byte3 = 3'b100;
parameter byte4 = 3'b101;

always @(posedge clk)
begin
    case(state)
        idle:
        begin
            busy <= 0;
            max_counter <= 0;
            if(enable)
                state <= byte1;
            else
                state <= idle;
        end

        byte1: begin
                    busy <= 1;
                    tx_data <= data_write[7:0];
                    dv <= 1;
            if(done)
            begin
                if(max_counter == s_strobe)
                        state <= idle;
                    else begin
                        state <= byte2;
                        dv <= 0;
                        max_counter <= max_counter + 1;
                    end
            end else
                state <= byte1;
            end

        byte2: begin
                tx_data <= data_write[15:8];
                dv <= 1;
                if(done) begin
                    if(max_counter == s_strobe)
                        state <= idle;
                    else begin
                        state <= byte3;
                        dv <= 0;
                        max_counter <= max_counter + 1;
                    end
            end else
                state <= byte2;
        end

        byte3: begin
                tx_data <= data_write[23:16];
                dv <= 1;
                if(done) begin
                    if(max_counter == s_strobe)
                            state <= idle;
                        else begin
                            state <= byte4;
                            dv <= 0;
                            max_counter <= max_counter + 1;
                        end
                end else
                    state <= byte3;
        end

        byte4: begin
                tx_data <= data_write[7:0];
                dv <= 1;
                if(done) begin
                    state <= idle;
                end else
                    state <= byte4;
    end
    endcase
end

endmodule
