
The design files are located at
C:/work_new/MGSG-CIS-S6-FX3CON/sch_rev100/codes/FPGA/ipcore_dir:

   - MIG_LPDDR.vho:
        vho template file containing code that can be used as a model
        for instantiating a CORE Generator module in a HDL design.

   - MIG_LPDDR.xco:
       CORE Generator input file containing the parameters used to
       regenerate a core.

   - MIG_LPDDR_flist.txt:
        Text file listing all of the output files produced when a customized
        core was generated in the CORE Generator.

   - MIG_LPDDR_readme.txt:
        Text file indicating the files generated and how they are used.

   - MIG_LPDDR_xmdf.tcl:
        ISE Project Navigator interface file. ISE uses this file to determine
        how the files output by CORE Generator for the core can be integrated
        into your ISE project.

   - MIG_LPDDR.gise and MIG_LPDDR.xise:
        ISE Project Navigator support files. These are generated files and
        should not be edited directly.

   - MIG_LPDDR directory.

In the MIG_LPDDR directory, three folders are created:
   - docs:
        This folder contains Virtex-6 FPGA Memory Interface Solutions user guide
        and data sheet.

   - example_design:
        This folder includes the design with synthesizable test bench.

   - user_design:
        This folder includes the design without test bench modules.

The example_design and user_design folders contain several other folders
and files. All these output folders are discussed in more detail in
Spartan-6 FPGA Memory Controller user guide (ug388.pdf) located in docs folder.
    