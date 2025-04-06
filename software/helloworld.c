/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"
#include "sleep.h"
#include "PmodOLEDrgb.h"
#include "xtmrctr.h"

int classify(const unsigned char *img);


// GPIO
volatile u32 * topl = (u32 *) XPAR_GPIO_TOPL_BASEADDR;
volatile u32 * botr = (u32 *) XPAR_GPIO_BOTR_BASEADDR;
volatile u32 * color = (u32 *) XPAR_GPIO_COLOR_BASEADDR;
volatile u32 * thickness = (u32 *)  XPAR_GPIO_THICKNESS_BASEADDR;
volatile u32 * resizer = (u32 *) XPAR_RESIZER_CONTROL_BASEADDR;
volatile u32 * knn_enable = (u32 *) XPAR_GPIO_KNN_ENABLE_BASEADDR;
volatile u32 * knn_value = (u32 *) XPAR_GPIO_KNN_DETECTED_BASEADDR;
volatile u32 * save_full_frame = (u32 *) XPAR_AXI_GPIO_SEND_FRAME_BASEADDR;


// MEMORY
volatile u32 * mem_base = (u32 *) (XPAR_MIG7SERIES_0_BASEADDR + 0x1000000);
#define MEM_BASE_DEF		(XPAR_MIG7SERIES_0_BASEADDR + 0x00100000)
//volatile u8 * RxBufferPtr = (u8 *) (mem_base + 0x1000000);
volatile u8 * OLED_buffer = (u8 *) (MEM_BASE_DEF + 0x1010000);


volatile float *tempbufp = (u8 *) (MEM_BASE_DEF + 0x1011000);
volatile u8 * full_frame_buf = (u8 *) (MEM_BASE_DEF + 0x1020000);


XAxiDma AxiDma;				// DMA
XAxiDma AxiDma2;				// DMA 2 - full frame
PmodOLEDrgb oledrgb;		// OLED
XTmrCtr TimerCounter;		// Timer


#define NUM_BYTES (28*28)

u8 rgbUserFont[] = {
   0x00, 0x04, 0x02, 0x1F, 0x02, 0x04, 0x00, 0x00, // 0x00
   0x0E, 0x1F, 0x15, 0x1F, 0x17, 0x10, 0x1F, 0x0E, // 0x01
   0x00, 0x1F, 0x11, 0x00, 0x00, 0x11, 0x1F, 0x00, // 0x02
   0x00, 0x0A, 0x15, 0x11, 0x0A, 0x04, 0x00, 0x00, // 0x03
   0x07, 0x0C, 0xFA, 0x2F, 0x2F, 0xFA, 0x0C, 0x07  // 0x04
}; // This table defines 5 user characters, although only one is used












// Helper functions
void change_box(int x1, int y1, int x2, int y2){
    *topl = (x1) + (y1 << 16);
    *botr = (x2) + (y2 << 16);

    *resizer = 0x7;
    //*resizer = 0x5;
    xil_printf("New Box - (%d, %d) - (%d, %d)\r\n", x1, y1, x2, y2);
}

void capture_box(u8 * buf){
	int Status;
	Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) buf,
				NUM_BYTES, XAXIDMA_DEVICE_TO_DMA);

	if (Status != XST_SUCCESS) {
		xil_printf("Failed\r\n");
		return XST_FAILURE;
	}

	// Toggle save resized frame - bit 3
	*resizer = *resizer | 0x8; // 0xd;
	*resizer = *resizer & (~0x8);//0x5;


	while(XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA)){

	}
}

// Prints the hex vlaues of buffer buf to std out
void print_buffer(u8 * buf){
    for(int i = 0; i < NUM_BYTES; i += 1){
    	//for(int j = 0; j < 28; j += 1){
    	//	xil_printf("%x ", RxBufferPtr[i*28 + j]);
    	//}
    	//xil_printf("\r\n");

    	xil_printf("%02x%02x%02x ", buf[i], buf[i], buf[i]);
    }

}
// Helper function: print a 28x28 image as ASCII art.
void print_image(unsigned char *image, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            unsigned char pixel = image[i * cols + j];
            char c;
            if (pixel > 230)
                c = '@';
            else if (pixel > 200)
                c = '#';
            else if (pixel > 150)
                c = '8';
            else if (pixel > 100)
                c = 'o';
            else if (pixel > 50)
                c = '.';
            else
                c = ' ';
            xil_printf("%c", c);
        }
        xil_printf("\n\r");
    }
}

void update_OLED(int hwval, int swval){

	char str_buf[2];
	str_buf[1] = 0;
	if(hwval < 0 || hwval >= 10 || swval < 0 || swval >= 10){
		xil_printf("Setting OLED to bad value!\r\n");
	}
	str_buf[0] = '0' + (hwval + 10) %10;

	OLEDrgb_SetCursor(&oledrgb, 7, 6);
	OLEDrgb_PutString(&oledrgb, str_buf); // Default color (green)

	str_buf[0] = '0' + (swval + 10) %10;

	OLEDrgb_SetCursor(&oledrgb, 3, 7);
	OLEDrgb_PutString(&oledrgb, str_buf); // Default color (green)
}


void print_OLED(u8 * buf){
    for(int i = 0; i < NUM_BYTES; i += 1){
    	u8 rounded = (buf[i] >> 4) & 0x0f; // 4 bits
    	OLED_buffer[i*2] = (rounded << 4) + rounded;
    	OLED_buffer[i*2 + 1] = rounded;
    }
    OLEDrgb_DrawBitmap(&oledrgb, 0, 0, 27, 27, (u8*) OLED_buffer);
	return;
}




void draw_block(u32 *buf, int x, int y, int t){

	buf[x + y*1280] = 0xffffff;
	buf[x + y*1280] = 0xffffff;
	buf[x + y*1280] = 0xffffff;
	return;
	for(int dy = y; dy <= dy + t; dy += 1)
	{
		for(int dx = x; dx <= x + t; dx += 1)
		{
			if(dx >= 0 && dx < 1280 && dy >= 0 && dy < 720){
				buf[dx + dy*1280] = 0xffffff;
			}
		}
	}

}


void draw_cord(u32 *buf, u32 topl, u32 botr){
	int x1 = topl & 0xffff;
	int y1 = (topl >> 16) & 0xffff;
	int x2 = botr & 0xffff;
	int y2 = (botr >> 16) & 0xffff;


	for(int y = y1; y < y2; y += 1)
	{
		draw_block(buf, x1, y, 1);
		draw_block(buf, x2, y, 1);
	}
	for(int x = x1; x <= x2; x += 1)
	{
		draw_block(buf, x, y1, 1);
		draw_block(buf, x, y2, 1);
	}

}


struct sub_cord{
	int ind;
	float left;
	float right;
};

typedef struct cord_t{
	struct sub_cord x;
	struct sub_cord y;
} cord_t;



float min(float a, float b){
	return (a < b) ? (a) : (b);
}
float max(float a, float b){
	return (a > b) ? (a) : (b);
}

// resamples the input frame into a 28x28 image with averaged luminance values
//			Luminance ~= 0.299*R + 0.587*G + 0.114*B
void resize_frame(u32 * buf_in, u8 * buf_out, int hdim, int vdim, int vstride){


	if(sizeof(float ) != sizeof(u32)){
		xil_printf("ERROR!\n\r");
		exit(1);
	}


	// 1) Convert to luminance
	float *fbuf = (float *) buf_in;

	for(int y = 0; y < vdim; y += 1)
	{
		for(int x = 0; x < hdim; x += 1)
		{
			u8 r = (buf_in[x + y*vstride] >> 0) & 0xff;
			u8 g = (buf_in[x + y*vstride] >> 8) & 0xff;
			u8 b = (buf_in[x + y*vstride] >> 16) & 0xff;

			float lum_f = 0.299*( (float) r) + 0.587*( (float) g) + 0.114*( (float) b); // 0 - 255
			fbuf[x + y*vstride] = lum_f;
		}
	}


	//float tempbuf[28*28] = {0};
	float *tempbuf = tempbufp;

	for(int i = 0; i < 28*28; i += 1){
		tempbuf[i] = 0.0f;
	}

	float dx = 28.0f / ((float)hdim);
	float dy = 28.0f / ((float)vdim);

	float norm = (783.0f) / ((float) hdim) * ((float) vdim);

	cord_t src = {{0, 0.0f, dx}, {0, 0.0f, dy}};
	cord_t dest = {{0, 0.0f, 1.0f}, {0, 0.0f, 1.0f}};

	while( (src.y.ind < vdim) && (dest.y.ind < 28) )
	{
		float factor_y = min(dest.y.right, src.y.right) - max(dest.y.left, src.y.left);

		src.x.ind = 0;
		src.x.left = 0.0f;
		src.x.right = dx;
		dest.x.ind = 0;
		dest.x.left = 0.0f;
		dest.x.right = 1.0f;

		while( (src.x.ind < hdim) && (dest.x.ind < 28)) // look at x effect only
		{
			// pixel: src_xl -> src_xr
			// dest: dest_xl -> dest_xr
			float factor_x = min(dest.x.right, src.x.right) - max(dest.x.left, src.x.left); // 0-1

			float value = fbuf[src.x.ind + src.y.ind*vstride];

			tempbuf[dest.x.ind + dest.y.ind*28] += factor_x*factor_y*value;


			if(dest.x.right > src.x.right){
				// increment pixel
				src.x.ind += 1;
				src.x.left += dx;
				src.x.right += dx;
			} else if(dest.x.right < src.x.right){
				// increment dest
				dest.x.ind += 1;
				dest.x.left += 1;
				dest.x.right += 1;
			} else{
				// increment both
				src.x.ind += 1;
				src.x.left += dx;
				src.x.right += dx;

				dest.x.ind += 1;
				dest.x.left += 1;
				dest.x.right += 1;
			}
		}

		if(dest.y.right > src.y.right){
			// increment pixel
			src.y.ind += 1;
			src.y.left += dy;
			src.y.right += dy;

		} else if(dest.y.right < src.y.right){
			// increment dest
			dest.y.ind += 1;
			dest.y.left += 1;
			dest.y.right += 1;
		} else{
			// increment both
			src.y.ind += 1;
			src.y.left += dy;
			src.y.right += dy;

			dest.y.ind += 1;
			dest.y.left += 1;
			dest.y.right += 1;
		}

	}



	// Normalize
	for(int y = 0; y < 28; y += 1)
	{
		for(int x = 0; x < 28; x += 1)
		{
			float lum_norm = tempbuf[x + y*28];
			u32 lum_int = (u32) lum_norm;
			if(lum_int >= 255){
				xil_printf("too big luminance!\n\r");
				exit(1);
			}

			buf_out[x + y*28] = (lum_int & 0xff);
		}
	}

}

// into full_frame_buf
void capture_full_frame(){
	int Status;
	Status = XAxiDma_SimpleTransfer(&AxiDma2, (UINTPTR) full_frame_buf,
				720*1280*4, XAXIDMA_DEVICE_TO_DMA);

	if (Status != XST_SUCCESS) {
		xil_printf("Failed\r\n");
		return XST_FAILURE;
	}

	// Toggle save frame
	*save_full_frame = 1;
	*save_full_frame = 0;

	while(XAxiDma_Busy(&AxiDma2, XAXIDMA_DEVICE_TO_DMA)){

	}
}


void disp_mode(u8 * dma_buf, u8 *oled_buf){


	xil_printf("Starting DMA->OLED pass-through loop\r\n");
    *resizer = *resizer | 0x2; // set update high
    *knn_enable = 1;

    u32 start_time, stop_time;
    int i = 0;

    start_time = XTmrCtr_GetValue(&TimerCounter, 0);
	XTmrCtr_Start(&TimerCounter, 0);


	while(1){

		int mode = 2;

		if(mode == 1)
		{
			capture_full_frame();
			int x1 = *topl & 0xffff;
			int y1 = (*topl >> 16) & 0xffff;
			int x2 = *botr & 0xffff;
			int y2 = (*botr >> 16) & 0xffff;
			resize_frame( ((u32 *)full_frame_buf) + x1 + y1*1280, dma_buf, x2 - x1, y2 - y1, 1280);

			print_OLED(dma_buf);		// Print frame
			int x = classify(dma_buf);	// Classify frame
			int y = *knn_value;			// Capture classifcation from HW
			update_OLED(y, x);			// Update with classification
		}
		else if(mode == 2)
		{
			capture_box(dma_buf); 		// Capture frame
			print_OLED(dma_buf);		// Print frame
			int x = classify(dma_buf);	// Classify frame
			int y = *knn_value;			// Capture classifcation from HW
			update_OLED(y, x);			// Update with classification
		}
		else if(mode == 3)
		{
			capture_box(dma_buf); 		// Capture frame
			print_OLED(dma_buf);		// Print frame
			int x = 0; //classify(dma_buf);	// Classify frame
			int y = *knn_value;			// Capture classifcation from HW
			update_OLED(y, x);			// Update with classification
		}
		else if(mode == 4)
		{
			int x = 0; //classify(dma_buf);	// Classify frame
			int y = *knn_value;			// Capture classifcation from HW
			update_OLED(y, x);			// Update with classification
		} else{
			//xil_printf("Starting\r\n");
			//resize_frame( ((u32 *)full_frame_buf) + 0 + 0*1280, dma_buf, 1280, 720, 1280);
			draw_cord(((u32 *)full_frame_buf), *topl, *botr);
			//xil_printf("Done\r\n");
		}


		if(XTmrCtr_GetValue(&TimerCounter, 0) - start_time >= 100000000){
			XTmrCtr_Stop(&TimerCounter, 0);
			stop_time = XTmrCtr_GetValue(&TimerCounter, 0);
			XTmrCtr_Reset(&TimerCounter, 0);

			u32 dt = (stop_time - start_time);
			xil_printf("Delta cycles = %u\r\n",  dt);
			float ncycles = (float) (stop_time - start_time);
			float time_ms = ncycles/(100000);
			float time_ks = time_ms/(1000000);
			float time_ks_inv = 1/time_ks;
			float frame_x_time_ks_inv = ( (float)(i + 1))*time_ks_inv;//60*time_ks_inv;
			float fps = frame_x_time_ks_inv/1000;

			float fps_x100 = fps*100.0f;
			int fps2 = (int) fps_x100;

			xil_printf("fps = %d.%02d\r\n",  (int) fps, fps2 % 100);


			i = 0;

			start_time = XTmrCtr_GetValue(&TimerCounter, 0);
			XTmrCtr_Start(&TimerCounter, 0);
		} else{
			i += 1;
		}

	}

}










int main()
{
    init_platform();

    print("Hello World\n\r");

    // 1) Set the box dims to match the initial coeffs in the resizing block
    *topl = (10) + (10 << 16);
    *botr = (100) + (100 << 16);
    *thickness = 1;
    *color = 0xff0000;

    // 2) Turn on the resizer - It will sync to vsync and do constant output
    // Take resizer out of reset - bit 2
    *resizer = 0x4;
    // Enable the resizer - bit 0
    *resizer = 0x5;


    // 3) set up the DMA 1
    // Setup resizer DMA and start a recive request for 784 bytes
    XAxiDma_Config *CfgPtr;
    int Status;
    u8 * RxBufferPtr = (u8 *) (mem_base + 0x1000000);
    for(int i = 0; i < NUM_BYTES; i += 1){
    	RxBufferPtr[i] = 0;
    }


	CfgPtr = XAxiDma_LookupConfig(XPAR_AXIDMA_1_DEVICE_ID);
	if (!CfgPtr) {
		xil_printf("No config found for %d\r\n", XPAR_AXIDMA_1_DEVICE_ID);
		return XST_FAILURE;
	}
	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DEVICE_TO_DMA);



    // 3.5) set up full frame DMA
    XAxiDma_Config *CfgPtr2;
    int Status2;

	CfgPtr2 = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
	if (!CfgPtr2) {
		xil_printf("No config found for %d\r\n", XPAR_AXIDMA_0_DEVICE_ID);
		return XST_FAILURE;
	}
	Status2 = XAxiDma_CfgInitialize(&AxiDma2, CfgPtr2);
	if (Status2 != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status2);
		return XST_FAILURE;
	}
	XAxiDma_IntrDisable(&AxiDma2, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DEVICE_TO_DMA);






	// 4) Init OLED
	OLEDrgb_begin(&oledrgb, XPAR_PMODOLEDRGB_0_AXI_LITE_GPIO_BASEADDR,
	         XPAR_PMODOLEDRGB_0_AXI_LITE_SPI_BASEADDR);
	// Define the user definable characters
	for (char ch = 0; ch < 5; ch++) {
	   OLEDrgb_DefUserChar(&oledrgb, ch, &rgbUserFont[ch * 8]);
	}


	OLEDrgb_SetCursor(&oledrgb, 0, 5);
	OLEDrgb_PutString(&oledrgb, "Detected"); // Default color (green)
	OLEDrgb_SetCursor(&oledrgb, 0, 6);
	OLEDrgb_PutString(&oledrgb, "Number:x"); // Default color (green)
	OLEDrgb_SetCursor(&oledrgb, 0, 7);
	OLEDrgb_PutString(&oledrgb, "SW:x"); // Default color (green)

	OLEDrgb_SetCursor(&oledrgb, 7, 6);
	OLEDrgb_PutString(&oledrgb, "-"); // Default color (green)
	OLEDrgb_SetCursor(&oledrgb, 3, 7);
	OLEDrgb_PutString(&oledrgb, "-"); // Default color (green)



	// 5) Init timer
	Status = XTmrCtr_Initialize(&TimerCounter, XPAR_TMRCTR_0_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		xil_printf("Timer initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}
	Status = XTmrCtr_SelfTest(&TimerCounter, 0);
	if (Status != XST_SUCCESS) {
		xil_printf("Timer self test failed %d\r\n", Status);
		return XST_FAILURE;
	}

	XTmrCtr_SetOptions(&TimerCounter, 0, XTC_AUTO_RELOAD_OPTION);




	// 6) Init SW controlled box
	int x1 = 200;
	int y1 = 200;
	int x2 = 600;
	int y2 = 600;
	int max_y = 719;
	int max_x = 1279;
	char c;
	//change_box(30, 200, 300, 350);
	change_box(x1, y1, x2, y2);


	/*capture_full_frame();
	xil_printf("Successfully captured full frame\r\n");
	resize_frame((u32 *)full_frame_buf, RxBufferPtr, 100, 100, 1280);
	print_OLED(RxBufferPtr);
	xil_printf("Done resizing\r\n");
	while(1){}*/

	disp_mode(RxBufferPtr, OLED_buffer);



	xil_printf("Resizing is in stream mode, starting command loop\r\n");


	int mode = 0; // 0=pos, 1=size
	while(1){
		xil_printf("Enter a command: \r\n");
		c = inbyte();
		switch(c){
		case 'p':
			xil_printf("Printing buffer\r\n");
			print_buffer(RxBufferPtr);
			break;
		case 'o':
			xil_printf("Printing ASCII art image\r\n");
			print_image(RxBufferPtr, 28, 28);
			break;
		case 'v':
			xil_printf("Showing saved image on OLED\r\n");
			print_OLED( (u8 *)RxBufferPtr);
			break;
		case 'c':
			xil_printf("Capturing a 28x28 frame\r\n");
			capture_box(RxBufferPtr);
			break;
		case 'm':
			if(mode == 0){
				xil_printf("Entering size mode\r\n");
				mode = 1;
			} else {
				xil_printf("Entering position mode\r\n");
				mode = 0;
			}
			break;
		case 'k':
			//xil_printf("Starting predictions...\r\n", x);
			int x = classify(RxBufferPtr);
			//for(int i = 0; i < 100; i += 1){
			//	x = classify(RxBufferPtr);
			//}
			xil_printf("Made a prediction on the saved image: %d\r\n", x);
			break;

		case 'w':
			if(mode == 0){ // pos
				xil_printf("Moving the box up\r\n");
				if(y1 - 10 >= 0){
					y1 = y1 - 10;
					y2 = y2 - 10;
				} else{
					y1 = y1 - (y1);
					y2 = y2 - (y1);
				}
			} else{ // size
				xil_printf("Making the box taller\r\n");
				if(y1 - 10 >= 0){
					y1 = y1 - 10;
				} else{
					y1 = y1 - (y1);
				}
				if(y2 + 10 <= max_y){
					y2 = y2 + 10;
				} else{
					y2 = max_y;
				}
			}
			change_box(x1, y1, x2, y2);
			break;
		case 's':
			if(mode == 0){ // pos
				xil_printf("Moving the box down\r\n");
				if(y2 + 10 <= max_y){
					y1 = y1 + 10;
					y2 = y2 + 10;
				} else{
					y1 = y1 + (max_y - y2);
					y2 = y2 + (max_y - y2);
				}
			} else{ // size
				xil_printf("Making the box shorter\r\n");
				if(y1 + 10 < y2 - 5){
					y1 = y1 + 10;
				} else{
					y1 = y2 - 5;
				}
				if(y2 - 10 > y1 + 5){
					y2 = y2 - 10;
				} else{
					y2 = y1 + 5;
				}
			}
			change_box(x1, y1, x2, y2);
			break;
		case 'a':
			if(mode == 0){ // pos
				xil_printf("Moving the box left\r\n");
				if(x1 - 10 >= 0){
					x1 = x1 - 10;
					x2 = x2 - 10;
				} else{
					x1 = x1 - (x1);
					x2 = x2 - (x1);
				}
			} else{ // size
				xil_printf("Making the box thinner\r\n");
				if(x1 + 10 < x2 - 5){
					x1 = x1 + 10;
				} else{
					x1 = x2 - 5;
				}
				if(x2 - 10 > x1 + 5){
					x2 = x2 - 10;
				} else{
					x2 = x1 + 5;
				}
			}
			change_box(x1, y1, x2, y2);
			break;
		case 'd': // NOT DONE
			if(mode == 0){ // pos
				xil_printf("Moving the box right\r\n");
				if(x2 + 10 <= max_x){
					x1 = x1 + 10;
					x2 = x2 + 10;
				} else{
					x1 = x1 + (max_x - x2);
					x2 = x2 + (max_x - x2);
				}
			} else{ // size
				xil_printf("Making the box wider\r\n");
				if(x1 - 10 >= 0){
					x1 = x1 - 10;
				} else{
					x1 = x1 - (x1);
				}
				if(x2 + 10 <= max_x){
					x2 = x2 + 10;
				} else{
					x2 = max_x;
				}
			}
			change_box(x1, y1, x2, y2);
			break;

		}

	}



    print("Successfully ran Hello World application");
    cleanup_platform();
    return 0;
}
