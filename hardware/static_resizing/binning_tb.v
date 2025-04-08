`timescale 1ns / 1ps

module binning_tb;

    // Clock and reset
    reg clk;
    reg resetn;

    // AXI Stream Interface
    reg [23:0] s_axis_tdata; // RGB input data
    reg s_axis_tvalid;
    wire s_axis_tready;

    // Output to SRAM buffer
    wire [31:0] addr;
    wire [31:0] wdata;
    wire wr_en;
    
    // N: delay wr_en by one clk cycle
//    reg wr_en_delayed; 
//    reg wr_en_captured;
    
    // Control and status
    reg start_bin;
    wire bin_done;

    // Instantiate binning module, DUT
    binning dut (
        .clk(clk),
        .resetn(resetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .addr(addr),
        .wdata(wdata),
        .wr_en(wr_en),
        .start_bin(start_bin),
        .bin_done(bin_done)
    );

    // Memory to hold image data
    reg [23:0] image_mem [0:307199]; // 307200 pixels (it should be in the data hex file)
    
    //N: Memory to simulate the SRAM
    reg [31:0] sram_mem [0:783]; 
    
    integer i;

    // Clock Generation
    always #5 clk = ~clk; // 10ns period (100 MHz)
    
    // N: Capture wr_en on clock edge
//    always @(posedge clk) begin
//        wr_en_captured <= wr_en;
//    end
    // Delay wr_en by one clock cycle
//    always @(posedge clk) begin
//        wr_en_delayed <= wr_en_captured;
//    end
        integer file;

    // Testbench
    initial begin
        // initialize signals
        clk = 0;
        resetn = 0;
        s_axis_tvalid = 0;
        start_bin = 0;

        $display("======== TESTBENCH STARTED =======");

        // Reset the system
        #20 resetn = 1;
        $display("[INFO] Reset deasserted. System initialized.");

        // Load data from the input hex file, which essentially comes from the RGB PNG image
        $display("[INFO] Loading image data from 'data_test_0.hex'...");
        $readmemh("data_test_0.hex", image_mem);
        $display("[SUCCESS] Image data loaded successfully.");

// Open the grayscale output file
        file = $fopen("grayscale_output.txt", "w");
        if (file == 0) begin
            $display("[ERROR] Failed to open file!");
            $finish;
        end


        // Start the binning process
        #10 start_bin = 1;
        $display("[INFO] Start signal asserted. Beginning binning process...");
        #10 start_bin = 0;

        // Send pixel data
        for (i = 0; i < 307200; i = i + 1) begin
            s_axis_tdata = image_mem[i]; // Assign pixel from memory
            s_axis_tvalid = 1;

            // wait for ready signal
            while (!s_axis_tready) #10;

            $display("[AXI RGB DATA IN] Sending Pixel %0d: R=%02X G=%02X B=%02X", i, image_mem[i][23:16], image_mem[i][15:8], image_mem[i][7:0]);
            
            #10; // Hold data for one clock cycle
        end

        // End transmission
        s_axis_tvalid = 0;
        $display("[INFO] All pixel data sent.");

        // wait for completing the full process
        wait (bin_done);
        $display("[SUCCESS] Binning process completed!");

        // Close the file
        $fclose(file);
        $display("[INFO] Grayscale data saved to grayscale_output.txt");


        // Finish simulation
        #20;
        $display("============ TESTBENCH FINISHED ==========");
        $finish;
    end
    
   // N: Simulate SRAM writes using delayed wr_en
    always @(posedge clk) begin
        if(wr_en) begin
            sram_mem[addr] = wdata;
            $display("SRAM Write: addr=%d, wdata=%h", addr, wdata);
            // Write grayscale values row by row
            $fwrite(file, "%h ", wdata[7:0]);
            if ((addr >> 2) % 28 == 27) begin
                $fwrite(file, "\n"); // Newline every 28 values
            end
        end
    end

endmodule
