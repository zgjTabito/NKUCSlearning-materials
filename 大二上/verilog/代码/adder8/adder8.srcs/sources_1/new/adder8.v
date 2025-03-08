module eightad(
    input [7:0] ain,
    input [7:0] bin,
    input cin,
    output [7:0] sumout,
    output cout
    );
    wire [7:0] carry;
    fulladder fad0(ain[0], bin[0], cin, sumout[0], carry[0]);
    fulladder fad1(ain[1], bin[1], carry[0], sumout[1], carry[1]);
    fulladder fad2(ain[2], bin[2], carry[1], sumout[2], carry[2]);
    fulladder fad3(ain[3], bin[3], carry[2], sumout[3], carry[3]);
    fulladder fad4(ain[4], bin[4], carry[3], sumout[4], carry[4]);
    fulladder fad5(ain[5], bin[5], carry[4], sumout[5], carry[5]);
    fulladder fad6(ain[6], bin[6], carry[5], sumout[6], carry[6]);
    fulladder fad7(ain[7], bin[7], carry[6], sumout[7], carry[7]);
    assign cout=carry[7];
endmodule