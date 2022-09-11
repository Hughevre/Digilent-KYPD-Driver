module cdc_single_bit_synchronizer #(
    parameter int unsigned ChainLength       = 4,
    parameter bit          IsInputRegistered = 1
) (
    // Primary side signals
    input  logic prim_clk_i,
    input  logic prim_i,

    // Secondary side signals
    input  logic sec_clk_i,
    output logic sec_o
);

    logic                                            async_bit;
    (* ASYNC_REG = "TRUE" *) logic [ChainLength-1:0] synchronizer_chain_shr;

    /**************************************************************************
     * Pre-registration of primary side signal logic
     *************************************************************************/
    generate
        if (IsInputRegistered) begin
            always_ff @(posedge prim_clk_i) begin
                async_bit <= prim_i;
            end
        end else begin
            assign async_bit = prim_i;
        end
    endgenerate

    /**************************************************************************
     * D-FF's synchronization chain logic
     *************************************************************************/
    always_ff @(posedge sec_clk_i) begin
        synchronizer_chain_shr <= {synchronizer_chain_shr[ChainLength-2:0], async_bit};
    end

    // Assign outputs
    assign sec_o = synchronizer_chain_shr[ChainLength-1];
endmodule