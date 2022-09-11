module digilent_kypd_decoder #(
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

    typedef enum logic [3:0] {
        IDLE  = 4'b0000,
        COL_1 = 4'b1000,
        COL_2 = 4'b0100,
        COL_3 = 4'b0010,
        COL_4 = 4'b0001
    } cols_scanner_state_e;

    typedef enum logic [3:0] {
        ROW_1 = 4'b0111,
        ROW_2 = 4'b1011,
        ROW_3 = 4'b1101,
        ROW_4 = 4'b1110,
        ROW_N = 4'b1111
    } rows_state_e;
    
    localparam int unsigned ColsScanningCounterMod   = ClockFrequencyInMHz / (2 * KeypadScanningFrequencyInMHz);
    localparam int unsigned ColsScanningCounterWidth = $clog2(ColsScanningCounterMod);
    localparam int unsigned DeferredDecoderMod       = 32;

    (* fsm_encoding = "user_encoding" *) cols_scanner_state_e cols_scanner_state_r;
    cols_scanner_state_e                                      cols_scanner_state_next;

    logic [ColsScanningCounterWidth-1:0] cols_scanning_cnt;
    logic                                next_col_switch_r;
    logic                                deferred_decoder_en_r;
    logic [3:0]                          pressed_key_code;

    /**************************************************************************
     * Columns driving logic
     *************************************************************************/
    // Counter used for scanning columns periodically
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            cols_scanning_cnt     <= '0;
            next_col_switch_r     <= '0;
            deferred_decoder_en_r <= '0;
        end else begin
            if (cols_scanning_cnt == ColsScanningCounterMod-1) begin
                cols_scanning_cnt <= '0;
                next_col_switch_r <= '1;
            end else if (cols_scanning_cnt == DeferredDecoderMod-1
            ) begin
                cols_scanning_cnt     <= cols_scanning_cnt + 1'b1;
                deferred_decoder_en_r <= '1;
            end else begin
                cols_scanning_cnt     <= cols_scanning_cnt + 1'b1;
                next_col_switch_r     <= '0;
                deferred_decoder_en_r <= '0;
            end
        end
    end

    // FSM state register and next-state logic
    always_ff @(posedge clk_i) begin
        if (reset_i) cols_scanner_state_r <= IDLE;
        else         cols_scanner_state_r <= cols_scanner_state_next;
    end

    always_comb begin
        unique case (cols_scanner_state_r)
            IDLE:                         cols_scanner_state_next = COL_1;

            COL_1: if (next_col_switch_r) cols_scanner_state_next = COL_2;
                   else                   cols_scanner_state_next = COL_1;

            COL_2: if (next_col_switch_r) cols_scanner_state_next = COL_3;
                   else                   cols_scanner_state_next = COL_2;

            COL_3: if (next_col_switch_r) cols_scanner_state_next = COL_4;
                   else                   cols_scanner_state_next = COL_3;

            COL_4: if (next_col_switch_r) cols_scanner_state_next = COL_1;
                   else                   cols_scanner_state_next = COL_4;
        endcase
    end

    // Logic used to negate one-hot encoded FSM states
    assign kypd_cols_o = ~cols_scanner_state_r;

    /**************************************************************************
     * Pressed key detector logic
     *************************************************************************/
    always_comb begin
        pressed_key_code = pressed_key_o;
        unique0 case (cols_scanner_state_r)
            COL_1: begin
                if (deferred_decoder_en_r) begin
                    if (kypd_rows_i == ROW_1)
                        pressed_key_code = 4'h1;
                    else if (kypd_rows_i == ROW_2)
                        pressed_key_code = 4'h4;
                    else if (kypd_rows_i == ROW_3)
                        pressed_key_code = 4'h7;
                    else if (kypd_rows_i == ROW_4)
                        pressed_key_code = 4'h0;
                end
            end

            COL_2: begin
                if (deferred_decoder_en_r) begin
                    if (kypd_rows_i == ROW_1)
                        pressed_key_code = 4'h2;
                    else if (kypd_rows_i == ROW_2)
                        pressed_key_code = 4'h5;
                    else if (kypd_rows_i == ROW_3)
                        pressed_key_code = 4'h8;
                    else if (kypd_rows_i == ROW_4)
                        pressed_key_code = 4'hF;
                end
            end

            COL_3: begin
                if (deferred_decoder_en_r) begin
                    if (kypd_rows_i == ROW_1)
                        pressed_key_code = 4'h3;
                    else if (kypd_rows_i == ROW_2)
                        pressed_key_code = 4'h6;
                    else if (kypd_rows_i == ROW_3)
                        pressed_key_code = 4'h9;
                    else if (kypd_rows_i == ROW_4)
                        pressed_key_code = 4'hE;
                end
            end

            COL_4: begin
                if (deferred_decoder_en_r) begin
                    if (kypd_rows_i == ROW_1)
                        pressed_key_code = 4'hA;
                    else if (kypd_rows_i == ROW_2)
                        pressed_key_code = 4'hB;
                    else if (kypd_rows_i == ROW_3)
                        pressed_key_code = 4'hC;
                    else if (kypd_rows_i == ROW_4)
                        pressed_key_code = 4'hD;
                end
            end
        endcase
    end

    // Register the outputs
    always_ff @(posedge clk_i) begin
        if (reset_i) pressed_key_o <= '0;
        else         pressed_key_o <= pressed_key_code;
    end
endmodule