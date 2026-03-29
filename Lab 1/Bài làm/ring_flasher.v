module ring_flash16 #(
    parameter integer STEP_DIV = 4
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rep_en,
    output reg [15:0] led
);

localparam IDLE    = 1'b0;
localparam RUNNING = 1'b1;
localparam DIR_CW  = 1'b1;
localparam DIR_CCW = 1'b0;

reg        state;
reg        dir;
reg [3:0]  idx;
reg [3:0]  seg_left;
reg [31:0] div_cnt;

wire step_tick;
wire [15:0] toggled_led;
wire seg_done;

assign step_tick   = (div_cnt == STEP_DIV-1);
assign toggled_led = led ^ (16'h0001 << idx);
assign seg_done    = (seg_left == 4'd1);

function [3:0] cw_next;
    input [3:0] pos;
    begin
        if (pos == 4'd15) cw_next = 4'd0;
        else              cw_next = pos + 4'd1;
    end
endfunction

function [3:0] ccw_next;
    input [3:0] pos;
    begin
        if (pos == 4'd0) ccw_next = 4'd15;
        else             ccw_next = pos - 4'd1;
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state    <= IDLE;
        dir      <= DIR_CW;
        idx      <= 4'd0;
        seg_left <= 4'd8;
        div_cnt  <= 32'd0;
        led      <= 16'h0000;
    end else begin
        case (state)
            IDLE: begin
                dir      <= DIR_CW;
                idx      <= 4'd0;
                seg_left <= 4'd8;
                div_cnt  <= 32'd0;
                led      <= 16'h0000;
                if (rep_en)
                    state <= RUNNING;
                else
                    state <= IDLE;
            end

            RUNNING: begin
                if (step_tick) begin
                    div_cnt <= 32'd0;

                    if (seg_done) begin
                        if (toggled_led == 16'h0000) begin
                            if (rep_en) begin
                                state    <= RUNNING;
                                dir      <= DIR_CW;
                                idx      <= 4'd0;
                                seg_left <= 4'd8;
                                led      <= 16'h0000;
                            end else begin
                                state    <= IDLE;
                                dir      <= DIR_CW;
                                idx      <= 4'd0;
                                seg_left <= 4'd8;
                                led      <= 16'h0000;
                            end
                        end else begin
                            state    <= RUNNING;
                            led      <= toggled_led;
                            idx      <= idx;
                            dir      <= ~dir;
                            if (dir == DIR_CW)
                                seg_left <= 4'd4;
                            else
                                seg_left <= 4'd8;
                        end
                    end else begin
                        state    <= RUNNING;
                        led      <= toggled_led;
                        seg_left <= seg_left - 4'd1;
                        if (dir == DIR_CW)
                            idx <= cw_next(idx);
                        else
                            idx <= ccw_next(idx);
                    end
                end else begin
                    div_cnt <= div_cnt + 32'd1;
                end
            end

            default: begin
                state    <= IDLE;
                dir      <= DIR_CW;
                idx      <= 4'd0;
                seg_left <= 4'd8;
                div_cnt  <= 32'd0;
                led      <= 16'h0000;
            end
        endcase
    end
end

endmodule