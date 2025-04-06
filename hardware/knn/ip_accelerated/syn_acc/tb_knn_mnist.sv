`timescale 1ns / 1ps

`define IMAGR_ROW 28
`define IMAGE_SIZE 784
`define NUM_TRAIN 100
`define K 3

module tb_knn_top();

    // Inputs
    logic [7:0] test_img [0:`IMAGE_SIZE-1]; // Test image (8-bit pixels)
    logic ap_clk;                          // Clock signal
    logic ap_rst;                          // Reset signal
    logic ap_start;                        // Start signal

    logic ap_done;
    logic ap_idle;
    logic ap_ready;
    logic image_r_ce0;
    logic [7:0] image_r_q0;
    logic image_r_ce1;
    logic [7:0] image_r_q1;
    logic [31:0] result;
    logic result_ap_vld;
    logic  [9:0] image_r_address0;
    logic  [9:0] image_r_address1;


    // Outputs
    logic [7:0] test_imgs[0: `NUM_TRAIN - 1][0: `IMAGE_SIZE - 1];
    logic [7:0] train_imgs[0 : `NUM_TRAIN - 1][0: `IMAGE_SIZE - 1];  // Array to store image data

    logic [3:0] res [0: `NUM_TRAIN - 1];
    integer accuray;
    integer count;
    integer j;
    integer k;
    // Instantiate the HLS-generated module
    knn_top DUT (
        //input 
        .ap_clk(ap_clk),
        .ap_rst(ap_rst),
        .ap_start(ap_start),
        .image_r_q0(image_r_q0),
        .image_r_q1(image_r_q1),
        //output
        .ap_done(ap_done),
        .ap_idle(ap_idle),
        .ap_ready(ap_ready),
        .image_r_address0(image_r_address0),
        .image_r_ce0(image_r_ce0),
        .image_r_address1(image_r_address1),
        .image_r_ce1(image_r_ce1),
        .result(result),
        .result_ap_vld(result_ap_vld)
    );
    initial begin 
        #9000000;
        $stop;
    end 
 
    // Clock generation
    initial begin 
        ap_clk = 0;
        forever #5 ap_clk = ~ap_clk;
    end 
 //read train image
task read_train_image();
    integer file;
    integer status;
    string line;
    logic [3:0] train_labels[`NUM_TRAIN];             // Array to store labels
    integer index;
    integer temp;
    integer row;
    integer start;
    integer img_index;
    integer comma_pos;

    // Open the file
    file = $fopen("C:/Users/miaqi/Documents/UofT_Docus/25_winter/ECE532/knn/mnist_test.csv", "r");
    if (file == 0) begin
        $display("Error: Cannot open file!");
        return; // Exit the task if the file cannot be opened
    end

    row = 0; // Initialize row counter
    while (row < `NUM_TRAIN && !$feof(file)) begin
        status = $fgets(line, file); // Read a line from the file
        if (status == 0) break;      // Exit if end of file or error
        // Find the position of the first comma (to skip the label)
        comma_pos = -1;
        for (int i = 0; i < line.len(); i++) begin
            if (line[i] == ",") begin
                comma_pos = i;
                break;
            end
        end

        // Extract the label (first value in the line)
        if (comma_pos != -1) begin
            string label_str;
            $display(label_str);

            label_str = line.substr(0, comma_pos - 1);
            train_labels[row] = label_str.atoi(); // Store the label
        end else begin
            $display("Error: No comma found in line!");
            break;
        end

        // Parse the rest of the line for image data
        start = comma_pos + 1; // Start after the first comma
        img_index = 0;         // Reset image data index

        for (int i = start; i < line.len(); i++) begin
            if (line[i] == "," || i == line.len() - 1) begin
                // Extract the substring between start and current index
                string substring;
                if (i == line.len() - 1) begin
                    substring = line.substr(start, i);
                end else begin
                    substring = line.substr(start, i - 1);
                end
            // $display(substring);
                // Convert the substring to an integer and store it in the array
                train_imgs[row][img_index] = substring.atoi();

                // Update the start index for the next substring
                start = i + 1;
                img_index = img_index + 1; // Move to the next image data index
            end
        end

        row = row + 1; // Move to the next row
    end

    $fclose(file); // Close the file

    // // Debug: Display the first few values for verification
    // $display("First label: %d", train_labels[0]);
    // $display("First image data:");
    // for (int i = 0; i < 10; i++) begin
    //     $write("%d ", train_imgs[0][i]);
    // end
    // $display("");
endtask

task read_test_image();
    integer file;
    integer status;
    string line;
    logic [7:0] train_imgs[`NUM_TRAIN][`IMAGE_SIZE];  // Array to store image data
    logic [3:0] train_labels[`NUM_TRAIN];             // Array to store labels
    integer index;
    integer temp;
    integer row;
    integer start;
    integer img_index;
    integer comma_pos;

    // Open the file
    file = $fopen("C:/Users/miaqi/Documents/UofT_Docus/25_winter/ECE532/knn/mnist_test.csv", "r");
    if (file == 0) begin
        $display("Error: Cannot open file!");
        return; // Exit the task if the file cannot be opened
    end

    row = 0; // Initialize row counter
    while (row < `NUM_TRAIN && !$feof(file)) begin
        status = $fgets(line, file); // Read a line from the file
        if (status == 0) break;      // Exit if end of file or error

        // Find the position of the first comma (to skip the label)
        comma_pos = -1;
        for (int i = 0; i < line.len(); i++) begin
            if (line[i] == ",") begin
                comma_pos = i;
                break;
            end
        end

        // Extract the label (first value in the line)
        if (comma_pos != -1) begin
            string label_str;
            label_str = line.substr(0, comma_pos - 1);
            res[row] = label_str.atoi(); // Store the label
        end else begin
            $display("Error: No comma found in line!");
            break;
        end

        // Parse the rest of the line for image data
        start = comma_pos + 1; // Start after the first comma
        img_index = 0;         // Reset image data index
        for (int i = start; i < line.len(); i++) begin
            if (line[i] == "," || i == line.len() - 1) begin
                // Extract the substring between start and current index
                string substring;
                if (i == line.len() - 1) begin
                    substring = line.substr(start, i);
                end else begin
                    substring = line.substr(start, i - 1);
                end

                // Convert the substring to an integer and store it in the array
                test_imgs[row][img_index] = substring.atoi();

                // Update the start index for the next substring
                start = i + 1;
                img_index = img_index + 1; // Move to the next image data index
            end
        end

        row = row + 1; // Move to the next row
    end

    $fclose(file); // Close the file

endtask
always_ff @(posedge ap_clk) begin 
    image_r_q0 <= test_img[image_r_address0];

end 
always_ff @(posedge ap_clk) begin 

    //  image_r_q0 <= test_img[image_r_address0];
     image_r_q1 <= test_img[image_r_address1];
end 
// always_comb @(image_r_address1)begin 
//      image_r_q1 = test_img[image_r_address1];
// end 
// Testbench logic
initial begin
    ap_start = 0;
    ap_rst = 0;
    // Initialize inputs
    // read_train_image(); //read 1024 train images for csv
    read_test_image(); //read 1024 test images for csv
    ap_start = 0;

    ap_rst = 0;
    @(posedge ap_clk);
    ap_rst = 1;
    #100;
    @(posedge ap_clk);
    ap_rst = 0;
    accuray = 0;
    for(integer i = 0; i < `NUM_TRAIN ; i = i + 1)begin
        test_img = test_imgs[i]; 
        wait(ap_idle == 1'b1);
        // Start computation
        count = 0;
        @(negedge ap_clk);
        ap_start=1;
        @(posedge ap_clk);
        @(posedge ap_clk);
        ap_start=0;
        // @(negedge image_r_ce0);
        // for(k= 0; k < 10; k = k +1)begin
        //     for(j = 0; j < 784; j = j +1)begin
        //         // if (k == 0)begin
        //         // fork
        //         //     begin
        //                 image_r_q0 = test_img[image_r_address0];
        //                 // @(negedge image_r_ce0);
        //             // end
        //             // begin
        //                 image_r_q1 = test_img[image_r_address1];
        //                 @(negedge image_r_ce1);
        //         //     end
        //         // join
        //         //     $display("send data %d, %d to address %d, %d", image_r_q0, image_r_q1, image_r_address0, image_r_address1);
        //         //     // count = count+1;
        //         // end 
        //         // else begin 
        //         //     image_r_q0 = 0;
        //         //     // count = count+1;
        //         // end
        //         // @(negedge image_r_ce0);
        //     end
        // end 

        // Wait for computation to complete
        wait (ap_done == 1);
        $display("Predicted Label: %d, Expected: %d", result, res[i]);
        // $assert(predicted_label != res[i]); //check if predicted label are matching
        if(result != res[i])begin 
            // $display("Error: predicted result not matched, Expected: %d", res[i]);
        end 
        else begin 
            accuray = accuray + 1;
        end 
    end
    
    $display("Accuracy: %d / 100", accuray);
    $finish;
end

endmodule