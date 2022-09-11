module debouncer #(
    parameter real ClockFrequencyInMHz     = 100.0,
    parameter real StabilityTimeInMicroSec = 1000.0
) (
    // Clocking and reset signals
    input  logic clk_i,
    input  logic reset_i,

    //
    input  logic ripple_i,
    output logic debounced_o
);

    localparam int unsigned StallCntMod   = ClockFrequencyInMHz * StabilityTimeInMicroSec;
    localparam int unsigned StallCntWidth = $clog2(StallCntMod);

    logic                     ripple_syn;
    logic                     ripple_syn_r;
    logic                     ripple_syn_r2;
    logic                     ripple_syn_pe;
    logic [StallCntWidth-1:0] stall_cnt;
    logic                     filtered_ripple_r;

    /**************************************************************************
     * Input ripple signal CDC synchronizer
     *************************************************************************/
    cdc_single_bit_synchronizer #(
        .ChainLength       (3),
        .IsInputRegistered (0)
    ) u_cdc_ripple_synchronizer (
        .prim_clk_i        (1'b0),
        .prim_i            (ripple_i),
        .sec_clk_i         (clk_i),
        .sec_o             (ripple_syn)
    );

    /**************************************************************************
     * Input ripple signal change detector
     *************************************************************************/
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            ripple_syn_r  <= '0;
            ripple_syn_r2 <= '0;
        end else begin
            ripple_syn_r  <= ripple_syn;
            ripple_syn_r2 <= ripple_syn_r;
        end
    end

    assign ripple_syn_pe = ripple_syn_r ^ ripple_syn_r2;

    /**************************************************************************
     * Ripple filter counter based logic
     *************************************************************************/
    always_ff @(posedge clk_i) begin
        if (reset_i || ripple_syn_pe) begin
            stall_cnt <= '0;
        end else begin
            if (stall_cnt == StallCntMod-1) begin
                stall_cnt         <= '0;
                filtered_ripple_r <= ripple_syn_r2;
            end else begin
                stall_cnt <= stall_cnt + 1'b1;
            end
        end
    end

    // Assign outputs
    assign debounced_o = filtered_ripple_r;
endmodule