`ifndef AHB_BUS_IF_VH
`define AHB_BUS_IF_VH

`include "common_types.vh"
import common_types_pkg::*;

interface ahb_bus_if;
    
    word_t haddr;
    logic [2:0] hburst;
    logic [1:0] hsize;
    htrans_t htrans;
    word_t hwdata;
    word_t hrdata;
    logic hready;
    logic hresp;
    logic hwrite;

    modport master (
        input hrdata, hready, hresp,
        output haddr, hburst, hsize, htrans, hwdata, hwrite
    );

    modport slave (
        input haddr, hburst, hsize, htrans, hwdata, hwrite,
        output hrdata, hready, hresp
    );
endinterface

`endif // AHB_BUS_IF_VH