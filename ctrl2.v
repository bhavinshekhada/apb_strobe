
module ctrl2 (
    input wire              clk,
    input wire              rst_n,
    input wire              empty,
    input wire [31:0]       data_read,  // 32-bit data read from FIFO
    output reg              read
   
);

    parameter IDLE_STATE = 2'b00;
    parameter READ_STATE = 2'b01;
    parameter TERMINATE = 2'b10;

    reg [1:0] state, next_state;
    reg [2:0] send_counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read <= 0;
            send_counter <= 0;
            state <= IDLE_STATE;
        end else begin
            case (state)
                IDLE_STATE: begin
                    read <= 0;
             if (!empty) begin
                        next_state = READ_STATE;
                    end else begin
                        next_state = IDLE_STATE;
                    end
                end
                READ_STATE: begin
                    read <= 1;
                 if (empty) begin
                        next_state = IDLE_STATE;
                    end else begin
                        next_state = TERMINATE;
                    end
                end
                TERMINATE: begin
                    read <= 0;
                  next_state = IDLE_STATE;
                end
            endcase
            state <= next_state;
        end
    end
endmodule
