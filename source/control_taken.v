module ctrl_T(input branch_and, input flush_on_not_taken);
    assign flush_on_not_taken = ~branch_and;
endmodule
