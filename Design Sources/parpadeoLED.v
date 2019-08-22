
/*********************************************************************
file: parpadeoLED
author: Arom Miranda
description:
-Simple 2sec blink to check visually the FPGA has the program
**********************************************************************/



module parpadeoLED #(parameter div_cantidad = 20000000)
(   input clock,
    input reset,
    output blink_led,   // User/boot LED next to power LED
    output salida_prueba  // extra
);

    // contador
    reg [30:0] blink_counter;

    //led
    reg r_led  = 1'b0;


    // increment the blink_counter every clock
    always @(posedge clock)
    begin

      if (reset) begin
          blink_counter <= 0;
          r_led = 0;
        end
        else begin
            if (blink_counter == div_cantidad-1)
            begin
              blink_counter <= 0;
              r_led = !r_led;
            end
            else
            blink_counter <= blink_counter+1;

            end
    end
    assign blink_led = r_led;

endmodule
