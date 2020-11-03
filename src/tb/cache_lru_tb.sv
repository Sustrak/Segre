module cache_lru_tb;
  	parameter NUMWAYS = 4;
  	localparam WIDTH = NUMWAYS*(NUMWAYS-1) >> 1;

  	logic [WIDTH-1:0] current, updated;
    logic [NUMWAYS-1:0] access, pre, post;

    mor1kx_cache_lru  u_lru (
        .current  (current),
        .update   (updated),
        .access   (access),
        .lru_pre  (pre),
        .lru_post (post)
    );
  
    initial begin
  	    current = 0;
        access = 0;
        
        #10;
        access = 4'b0001;
        do_print;
        #10;
        access = 4'b0010;
        current = updated;
        do_print;
        #10;
        access = 4'b0100;
        current = updated;
        do_print;
        #10;
        access = 4'b1000;
        current = updated;
        do_print;
        #10;
        access = 4'b0001;
        current = updated;
        do_print;
         #10;
        access = 4'b0010;
        current = updated;
        do_print;
         #10;
        access = 4'b0001;
        current = updated;
        do_print;
         #10;
        access = 4'b0010;
        current = updated;
        do_print;
         #10;
        access = 4'b1000;
        current = updated;
        do_print;
         #10;
        access = 4'b0100;
        current = updated;
        do_print;
        #10;
        access = 4'b0000;
        current = updated;
        do_print;
    end
  
    function do_print;
        $display("current: %0b", current);
        $display("updated: %0b", updated);
        $display("access : %0b", access);
        $display("pre    : %0b", pre);
        $display("post   : %0b", post);
        $display("---------------");
    endfunction
endmodule
