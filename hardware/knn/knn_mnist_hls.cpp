#include "ap_int.h"
#include "ap_fixed.h"
#include "hls_stream.h"

// Define constants.
#define K 3
#define NUM_TRAIN 1024   // Use a subset of training images.
#define IMAGE_SIZE 784   // 28x28 images.
#define NUM_CLASSES 10

// Fixed-point type for distance calculation.
typedef ap_ufixed<32, 16> fixed_t;

// Top-level function for HLS synthesis.
int knn_top(unsigned char test_img[IMAGE_SIZE]) {
// #pragma HLS INTERFACE bram port=test_img
#pragma HLS INTERFACE s_axilite port=test_img bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

    // Static arrays for training data stored in BRAM.
    static unsigned char train_imgs[NUM_TRAIN][IMAGE_SIZE];
    #pragma HLS RESOURCE variable=train_imgs core=RAM_1P_BRAM
    #pragma HLS ARRAY_PARTITION variable=train_imgs cyclic factor=16 dim=2  // Reduced partitioning factor.
    static unsigned char train_labels[NUM_TRAIN];
    #pragma HLS RESOURCE variable=train_labels core=RAM_1P_BRAM

    // Fixed-point kNN classification.
    fixed_t best_distances[K];
    int best_indices[K];
    for (int j = 0; j < K; j++) {
#pragma HLS PIPELINE II=1
        best_distances[j] = fixed_t(0xFFFF);  // Max value for fixed_t.
        best_indices[j] = -1;
    }

    // Iterate over the training set.
    for (int i = 0; i < NUM_TRAIN; i++) {
#pragma HLS PIPELINE II=1
        fixed_t dist = 0;
        // Compute the squared Euclidean distance.
        for (int p = 0; p < IMAGE_SIZE; p++) {
#pragma HLS UNROLL factor=16   // Reduced unrolling factor.
            int diff = (int)test_img[p] - (int)train_imgs[i][p];
            dist += fixed_t(diff * diff);
        }
        // Update the best K distances.
        int max_idx = 0;
        for (int j = 1; j < K; j++) {
#pragma HLS UNROLL
            if (best_distances[j] > best_distances[max_idx])
                max_idx = j;
        }
        if (dist < best_distances[max_idx]) {
            best_distances[max_idx] = dist;
            best_indices[max_idx] = i;
        }
    }
    
    // Voting for the final prediction.
    int votes[NUM_CLASSES] = {0};
#pragma HLS ARRAY_PARTITION variable=votes complete dim=1
    for (int j = 0; j < K; j++) {
#pragma HLS UNROLL
        if (best_indices[j] != -1) {
            votes[ train_labels[ best_indices[j] ] ]++;
        }
    }
    
    int predicted = 0;
    int max_votes = votes[0];
    for (int d = 1; d < NUM_CLASSES; d++) {
#pragma HLS UNROLL
        if (votes[d] > max_votes) {
            max_votes = votes[d];
            predicted = d;
        }
    }
    
    return predicted;
}