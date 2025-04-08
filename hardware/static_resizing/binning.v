module binning(
    input wire clk,
    input wire resetn,
    // AXI Stream Slave input from CPU (or Master)
    input wire [23:0] s_axis_tdata, // stream of data coming in that is in RGB 
    input wire s_axis_tvalid, // Data valid signal from the master
    output wire s_axis_tready, // Ready signal to the master (slave to master)
    // Output to SRAM buffer - Starts at address 0x0
    output wire [31:0] addr,
    output reg [31:0] wdata,  // Changed from wire to reg
    output wire wr_en,
    // Control and status signals
    input wire start_bin, // Command to start the resizing
    output wire bin_done // Asserted once you have read the whole image
);

    // State machine for resizing process
    parameter IDLE = 2'b00;
    parameter RESIZING = 2'b01;
    parameter DONE = 2'b10;
    
    reg [31:0] gray_sum_reg; // register for gray_sum
    
    reg [7:0] gray_avg_reg;
    
    reg [1:0] state;
    reg [1:0] next_state;

    // registers for resizing logic
    reg [7:0] red, green, blue;
    reg [15:0] gray_temp;
    reg [7:0] gray; // Grayscale value of the pixel
    reg [31:0] pixel_count;

    // parameters
    localparam integer RESIZE_WIDTH = 640 / 28; // 23
    localparam integer RESIZE_HEIGHT = 480 / 28; // 17
    localparam integer OUT_WIDTH = 28; // out width
    localparam integer OUT_HEIGHT = 28; // out height
    localparam integer BIN_SIZE = 784; // total quadrants = 28x28=784
    // BIN_PIXEL_COUNT
    localparam integer BIN_PIXEL_COUNT = RESIZE_WIDTH * RESIZE_HEIGHT; //391
    
    // Grayscale sums for each quadrant
    reg [31:0] gray_sum [0:BIN_SIZE - 1]; // Array to store sums of grayscale values for each bin
    reg [31:0] pixel_sum; // Sum of pixel values for the current quadrant/bin
    reg [10:0] pixel_count_in_bin; // Pixel count for the current quadrant/bin
    reg [10:0] current_bin; // quadrant index, goes from 0-783

    // grayscale Conversion
    // weighted grayscale conversion based on the luminance of the colors
    // Red: 77, Green: 150, Blue: 29
    // Y=0.2126×R+0.7152×G+0.0722×B
    // where the values 8'd54, 8'd183, and 8'd19 are scaled approximations of the exact luminance coefficients multiplied by 256, or shifted by 8
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            red <= 0;
            green <= 0;
            blue <= 0;
            gray <= 0;
        end else if (s_axis_tvalid) begin
            red <= s_axis_tdata[23:16];
            green <= s_axis_tdata[15:8];
            blue <= s_axis_tdata[7:0];
            gray_temp <= (red * 8'd54 + green * 8'd183 + blue * 8'd19); // to prevent overflowing and making sure GRAY calculation is not 0
            gray <= gray_temp >> 8;
            //gray <= (red * 8'd54 + green * 8'd183 + blue * 8'd19) >> 8;
            // Display statement for grayscale calculation
            $display("IN HEX, RGB: R=%h, G=%h, B=%h, IN DECIMAL, GRAY!!!=%d", red, green, blue, gray);        
        end
    end

    // FSM state machine
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            pixel_count <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin // this block is sensitive to any change in the input signals
        case (state)
            IDLE: next_state = start_bin ? RESIZING : IDLE; // conditional statement, if start_bin is 1, then next state is RESIZING, otherwise if 0, then it would be in state IDLE 
            RESIZING: next_state = (pixel_count == 640*480) ? DONE : RESIZING; // conditional statement, if pixel_count is 640*480, all pixels have been processed, then next_state is DONE, otherwise stay in RESIZING
            DONE: next_state = IDLE; // in DONE state, the FSM will transition to the IDLE state
            default: next_state = IDLE;
        endcase
    end

    // pixel processing and binning
    // this logic is synchronous to the pos edge of clk or falling edge of the reset 
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
        // registers are reset to their initial values, to ensure it starts at a known state
            pixel_count <= 0;
            pixel_sum <= 0;
            pixel_count_in_bin <= 0;
            current_bin <= 0;
            gray_avg_reg <= 0;
        end else if (state == RESIZING && s_axis_tvalid) begin // if resetn is 1 and the FSM is in RESIZING state, and the input data stream is valid
            pixel_sum <= pixel_sum + gray; // adding the pixel's grayscale value to the pixel_sum
            pixel_count_in_bin <= pixel_count_in_bin + 1; //  increments the pixel count within the current bin
            $display("PIXEL COUNT IN BIN: %d", pixel_count_in_bin); // debug statements

            if (pixel_count_in_bin == BIN_PIXEL_COUNT) begin // if the bin is completed with full pixel count for that specific bin
            gray_sum[current_bin] <= pixel_sum >> 11;
 $display("BIN %d: pixel_sum=%d, pixel_count_in_bin=%d, AVG=%d", current_bin, pixel_sum, BIN_PIXEL_COUNT, gray_sum[current_bin]);            gray_avg_reg <= pixel_sum >> 11;  // Shift instead of division

                // Reset pixel count and sum for next bin
                pixel_count_in_bin <= 0;
                pixel_sum <= 0;

                // Increment current_bin only if we are not at the last bin
                if (current_bin < BIN_SIZE - 1) begin
                    current_bin <= current_bin + 1;
                end
            end

            pixel_count <= pixel_count + 1;
        end
    end


    //output logic, AXI Stream interface control, completion signaling, debugging, and the data written to SRAM
    
    assign addr = current_bin; // SRAM address (addr) is assigned the value of current_bin, each bin's average grayscale value will be written to a sequential address in the SRAM
    
    //wr_en is set to 1 when 
    //    1.   FSM is in the RESIZING state
    //    2.   pixel_count_in_bin is 0, bin has just finished processing and result is ready to be written
    //    3.   pixel_count is not 0 to prevent wr_en on first clk cycle of resizing state
    //assign wr_en = (state == RESIZING && pixel_count_in_bin == 0 && pixel_count != 0);
     assign wr_en = (state == RESIZING && pixel_count_in_bin == BIN_PIXEL_COUNT && pixel_count != 0);
    
    // AXI Stream Slave Interface
    // asserted only when the FSM is in RESIZING state
    assign s_axis_tready = (state == RESIZING); 

    // Assert bin_done when the state is DONE and the last bin is processed
    assign bin_done = (state == DONE && current_bin == BIN_SIZE - 1); // 784-1 = 783, so at the 783 bin, this signal will assert

    // debugging statements, for monitoring, need to fix the gray value
    always @(posedge clk) begin
        if (state == RESIZING) begin
            $display("IN HEX, Red: %h, Green: %h, Blue: %h, IN HEX, GRAY!!!: %h", red, green, blue, gray);
            $display("State: RESIZING, current_bin: %d, pixel_count: %d", current_bin, pixel_count);
        end else if (state == DONE) begin
            $display("State: DONE, current_bin: %d, pixel_count: %d", current_bin, pixel_count);
        end
    end

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wdata <= 32'b0;
    end else if (wr_en) begin
        wdata <= gray_avg_reg;  // Store the stable computed bin average
        $display("WDATA WRITE: addr=0x%h, wdata=%d (current_bin=%d, gray_avg_reg=%d)", 
                 addr, wdata, current_bin, gray_avg_reg);
    end else begin
        wdata <= 32'b0;
    end
end
endmodule
