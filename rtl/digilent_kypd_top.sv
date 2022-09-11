module digilent_kypd_top #(
    parameter real ClockFrequencyInMHz          = 100.0,
    parameter real KeypadScanningFrequencyInMHz = 1.0
) (
    // Clocking and reset signals
    input  logic       clk_i,
    input  logic       reset_i,

    // Digilent PMOD KYPD rows and columns signals
    input  logic [3:0] kypd_rows_i,
    output logic [3:0] kypd_cols_o,

    // Detected key signal encoded in HEX format
    output logic [3:0] pressed_key_o
);

    logic [3:0] kypd_rows_debounced;

    digilent_kypd_decoder #(
        .ClockFrequencyInMHz          (ClockFrequencyInMHz),
        .KeypadScanningFrequencyInMHz (KeypadScanningFrequencyInMHz)
    ) u_digilent_kypd_decoder (
        .clk_i                        (clk_i),
        .reset_i                      (reset_i),
        .kypd_rows_i                  (kypd_rows_debounced),
        .kypd_cols_o                  (kypd_cols_o),
        .pressed_key_o                (pressed_key_o)
    );

    generate
        genvar i;
        for (i = 0; i < 4; i++) begin
            debouncer #(
                .ClockFrequencyInMHz     (ClockFrequencyInMHz),
                .StabilityTimeInMicroSec (0.08)
            ) u_row_ripple_remover (
                .clk_i                   (clk_i),
                .reset_i                 (reset_i),
                .ripple_i                (kypd_rows_i[i]),
                .debounced_o             (kypd_rows_debounced[i])
            );
        end
    endgenerate
endmodule