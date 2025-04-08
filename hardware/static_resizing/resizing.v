timescale 1ns / 1ps

module resizing(
    input wire clk,
    input wire resetn,
    // AXI Stream Slave input from CPU (or Master)
    input wire [23:0] s_axis_tdata, // {R[7:0], G[7:0], B[7:0]}
    input wire s_axis_tvalid, // Data valid signal from the master
    output wire s_axis_tready, // Ready signal to the master (slave to master)
    // Output to SRAM buffer - Starts at address 0x0
    output wire [31:0] addr,
    input wire [31:0] rdata, // Unused in this version, remove if not needed
    output wire [31:0] wdata,
    output wire wr_en,
    // Control and status signals
    input wire start_bin, // Command to start the resizing
    output wire bin_done // Asserted once you have read the whole image
);

    // State machine for resizing process
    parameter IDLE = 2'b00;
    parameter RESIZING = 2'b01;
    parameter DONE = 2'b10;

    reg [1:0] state, next_state;

    // Internal registers for resizing logic
    reg [7:0] red, green, blue;
    reg [15:0] gray; // Grayscale value of the pixel
    reg [31:0] pixel_count;
    reg [15:0] avg_gray; // Average grayscale value after resizing

    // Parameters for resizing
    localparam integer RESIZE_WIDTH = 640 / 28; // Calculate the width of each bin
    localparam integer RESIZE_HEIGHT = 480 / 28; // Calculate the height of each bin
    localparam integer OUT_WIDTH = 28; // Resized width
    localparam integer OUT_HEIGHT = 28; // Resized height
    localparam integer BIN_SIZE = 784; // Total bins = 28 * 28

    // Grayscale sums for each quadrant
    reg [31:0] gray_sum [0:BIN_SIZE - 1]; // Array to store sums of grayscale values for each bin
    reg [31:0] pixel_sum; // Sum of pixel values for the current bin
    reg [10:0] pixel_count_in_bin; // Pixel count for the current bin
    reg [10:0] current_bin; // Bin index
    reg [10:0] image_row_counter;
    reg [10:0] image_col_counter;

    // Parameters to iterate over image dimensions
    localparam integer ROWS_IN_IMAGE = 480;
    localparam integer COLS_IN_IMAGE = 640;

    // Logic to convert RGB to grayscale (using 0.299*R + 0.587*G + 0.114*B approximation)
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            red <= 0;
            green <= 0;
            blue <= 0;
        end else if (s_axis_tvalid) begin
            red <= s_axis_tdata[23:16];
            green <= s_axis_tdata[15:8];
            blue <= s_axis_tdata[7:0];
        end
    end

    // Convert RGB to grayscale using weighted average
    always @(posedge clk) begin
        if (s_axis_tvalid) begin
            gray <= (red * 8'd77 + green * 8'd150 + blue * 8'd29) >> 8;
        end
    end

    // State machine for resizing process
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            pixel_count <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(state or s_axis_tvalid or pixel_count) begin
        case (state)
            IDLE: begin
                if (start_bin)
                    next_state = RESIZING;
                else
                    next_state = IDLE;
            end
            RESIZING: begin
                if (pixel_count == ROWS_IN_IMAGE * COLS_IN_IMAGE) begin
                    next_state = DONE;
                end else begin
                    next_state = RESIZING;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Logic to process and accumulate pixel grayscale values into bins
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pixel_count <= 0;
            pixel_sum <= 0;
            pixel_count_in_bin <= 0;
            current_bin <= 0;
            image_row_counter <= 0;
            image_col_counter <= 0;
        end else if (state == RESIZING && s_axis_tvalid) begin
            // Accumulate grayscale values for each pixel in the current bin
            pixel_sum <= pixel_sum + gray;
            pixel_count_in_bin <= pixel_count_in_bin + 1;

            // Once we've processed a bin, save the sum and reset counters
            if (pixel_count_in_bin == RESIZE_WIDTH * RESIZE_HEIGHT) begin
                gray_sum[current_bin] <= pixel_sum / (RESIZE_WIDTH * RESIZE_HEIGHT); // Average grayscale value
                pixel_count_in_bin <= 0;
                pixel_sum <= 0;
                current_bin <= current_bin + 1;
            end

            // Count pixels across the entire image
            pixel_count <= pixel_count + 1;
            image_col_counter <= image_col_counter + 1;
            if(image_col_counter == COLS_IN_IMAGE) begin
                image_col_counter <=0;
                image_row_counter <= image_row_counter +1;
            end
        end
    end

    // Output logic to SRAM
    assign wdata = {16'b0, gray_sum[current_bin]}; // Write the current sum to SRAM
    assign addr = current_bin; // Address the SRAM for each bin
    assign wr_en = (state == RESIZING && pixel_count_in_bin == 0 && pixel_count != 0);

    // Control signals for AXI Stream Slave Interface
    assign s_axis_tready = (state == RESIZING);
    assign bin_done = (state == DONE && current_bin == BIN_SIZE);

endmodule