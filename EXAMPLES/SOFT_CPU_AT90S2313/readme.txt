SOFT CPU core example AT90S2313 using opencores AX8
  https://opencores.org/projects/ax8

open AVR_AT90S2313\AVR_AT90S2313.aps and build AVRSTUDIO AVRSTUDIO 4.19 build 730

ecexute AVR_AT90S2313\default\hex2rom_2313.bat

open AVR_AT90S2313\default\AT90S2313_ROM.vhd
open FPGA\rtl\ax8_opencores_vhdl\ax8_opencores_vhdl\mem1.vhd
copy brom231300 lines in the AT90S2313_ROM.vhd to RAMB16BWE_S18_S9_inst_LSB INIT_00~
copy brom231301 lines in the AT90S2313_ROM.vhd to RAMB16BWE_S18_S9_inst_MSB INIT_00~
and fill zeros unused ROMs

open FPGA project using ISE14.7
generate programming file
