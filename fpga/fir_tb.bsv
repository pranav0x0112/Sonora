package fir_tb;

import FIR::*;
import Vector::*;
import StmtFSM::*;

(* synthesize *)
module mkTest(Empty);
    FIR_IFC fir <- mkFIR;
    
    Reg#(UInt#(8)) sample_count <- mkReg(0);
    Reg#(Bool) done <- mkReg(False);

    Stmt test_seq = seq
        $display("=== FIR Filter Impulse Response Test ===");

        action
            fir.put(32767);
        endaction

        action
            let y <- fir.get();
            $display("OUTPUT[0] = %0d", y);
            fir.put(0);
        endaction

        while (sample_count < 30) seq
            action
                let y <- fir.get();
                $display("OUTPUT[%0d] = %0d", sample_count + 1, y);
                sample_count <= sample_count + 1;
                if (sample_count < 29) begin
                    fir.put(0);
                end
            endaction
        endseq
        
        $display("=== Test Complete ===");
        done <= True;
    endseq;
    
    FSM test_fsm <- mkFSM(test_seq);
    
    rule start;
        test_fsm.start();
    endrule
    
    rule finish (done);
        $finish(0);
    endrule

endmodule

endpackage