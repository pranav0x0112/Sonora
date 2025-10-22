package FIR;

import Vector::*;

interface FIR_IFC;
    method Action put(Int#(16) x);
    method ActionValue#(Int#(64)) get();
endinterface

(* synthesize *)
module mkFIR(FIR_IFC);
    // Q15 coefficients - use a function to initialize
    function Vector#(31, Int#(16)) initCoeffs();
        Vector#(31, Int#(16)) c = newVector;
        c[0]  = 1;     // 0.00002833
        c[1]  = 5;     // 0.00013774
        c[2]  = 8;     // 0.00023770
        c[3]  = 0;     // -0.00000000
        c[4]  = -37;   // -0.00112939
        c[5]  = -118;  // -0.00360089
        c[6]  = -233;  // -0.00712307
        c[7]  = -328;  // -0.01000410
        c[8]  = -294;  // -0.00898370
        c[9]  = 0;     // 0.00000000
        c[10] = 659;   // 0.02010108
        c[11] = 1689;  // 0.05153481
        c[12] = 2958;  // 0.09028054
        c[13] = 4209;  // 0.12845765
        c[14] = 5131;  // 0.15658694
        c[15] = 5471;  // 0.16695272 (center tap)
        c[16] = 5131;  // 0.15658694
        c[17] = 4209;  // 0.12845765
        c[18] = 2958;  // 0.09028054
        c[19] = 1689;  // 0.05153481
        c[20] = 659;   // 0.02010108
        c[21] = 0;     // 0.00000000
        c[22] = -294;  // -0.00898370
        c[23] = -328;  // -0.01000410
        c[24] = -233;  // -0.00712307
        c[25] = -118;  // -0.00360089
        c[26] = -37;   // -0.00112939
        c[27] = 0;     // -0.00000000
        c[28] = 8;     // 0.00023770
        c[29] = 5;     // 0.00013774
        c[30] = 1;     // 0.00002833
        return c;
    endfunction
    
    Vector#(31, Int#(16)) coeffs = initCoeffs();

    Vector#(31, Reg#(Int#(16))) shift_reg <- replicateM(mkReg(0));

    method Action put(Int#(16) x);
        for (Integer i = 30; i > 0; i = i - 1)
            shift_reg[i] <= shift_reg[i-1];
        shift_reg[0] <= x;
    endmethod

    method ActionValue#(Int#(64)) get();
        Int#(64) sum = 0; 
        for (Integer i = 0; i < 31; i = i + 1) begin
            Int#(64) sr_val = signExtend(shift_reg[i]);
            Int#(64) coeff_val = signExtend(coeffs[i]);
            Int#(64) prod = sr_val * coeff_val;
            sum = sum + prod;
        end

        Int#(64) rounding = (sum >= 0) ? 16384 : -16384;  // 2^14
        Int#(64) out = (sum + rounding) >> 15;
        
        return out;
    endmethod

endmodule

endpackage