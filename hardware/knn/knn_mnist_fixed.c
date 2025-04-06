#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <omp.h>
#include <time.h>
#include <limits.h>   

#define K 3

// Structure for MNIST images
typedef struct {
    int num_images;
    int rows;
    int cols;
    unsigned char *data;
} MNISTImages;

// Structure for MNIST labels
typedef struct {
    int num_labels;
    unsigned char *data;
} MNISTLabels;

// Read a 4-byte big-endian integer from a file.
int read_int(FILE *fp) {
    unsigned char buffer[4];
    if (fread(buffer, sizeof(unsigned char), 4, fp) != 4) {
        fprintf(stderr, "Error reading integer from file\n");
        exit(1);
    }
    return (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
}

// Load MNIST image file (IDX format)
MNISTImages* load_mnist_images(const char *filename) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        perror("Error opening image file");
        exit(1);
    }
    int magic = read_int(fp);
    if (magic != 2051) {
        fprintf(stderr, "Invalid magic number in image file: %d\n", magic);
        exit(1);
    }
    int num_images = read_int(fp);
    int rows = read_int(fp);
    int cols = read_int(fp);
    int image_size = rows * cols;
    
    unsigned char *data = (unsigned char *)malloc(num_images * image_size * sizeof(unsigned char));
    if (!data) {
        fprintf(stderr, "Unable to allocate memory for images\n");
        exit(1);
    }
    size_t read_bytes = fread(data, sizeof(unsigned char), num_images * image_size, fp);
    if (read_bytes != (size_t)(num_images * image_size)) {
        fprintf(stderr, "Error reading image data\n");
        exit(1);
    }
    fclose(fp);
    
    MNISTImages *images = (MNISTImages *)malloc(sizeof(MNISTImages));
    images->num_images = num_images;
    images->rows = rows;
    images->cols = cols;
    images->data = data;
    return images;
}

// Load MNIST label file (IDX format)
MNISTLabels* load_mnist_labels(const char *filename) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        perror("Error opening label file");
        exit(1);
    }
    int magic = read_int(fp);
    if (magic != 2049) {
        fprintf(stderr, "Invalid magic number in label file: %d\n", magic);
        exit(1);
    }
    int num_labels = read_int(fp);
    
    unsigned char *data = (unsigned char *)malloc(num_labels * sizeof(unsigned char));
    if (!data) {
        fprintf(stderr, "Unable to allocate memory for labels\n");
        exit(1);
    }
    size_t read_bytes = fread(data, sizeof(unsigned char), num_labels, fp);
    if (read_bytes != (size_t)num_labels) {
        fprintf(stderr, "Error reading label data\n");
        exit(1);
    }
    fclose(fp);
    
    MNISTLabels *labels = (MNISTLabels *)malloc(sizeof(MNISTLabels));
    labels->num_labels = num_labels;
    labels->data = data;
    return labels;
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
            printf("%c", c);
        }
        printf("\n");
    }
}

int main(int argc, char *argv[]) {
    srand(time(NULL));  // Seed for random output printing
    
    int visualize = 0; // -v flag prints output visual.

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-v") == 0) {
            visualize = 1;
            for (int j = i; j < argc - 1; j++) {
                argv[j] = argv[j + 1];
            }
            argc--;
            break;
        }
    }
    
    if (argc != 5) {
        printf("Usage: %s [-v] <train-images-idx3-ubyte> <train-labels-idx1-ubyte> <test-images-idx3-ubyte> <test-labels-idx1-ubyte>\n", argv[0]);
        return 1;
    }
    
    printf("Loading training images...\n");
    MNISTImages *train_images = load_mnist_images(argv[1]);
    printf("Loading training labels...\n");
    MNISTLabels *train_labels = load_mnist_labels(argv[2]);
    printf("Loading test images...\n");
    MNISTImages *test_images = load_mnist_images(argv[3]);
    printf("Loading test labels...\n");
    MNISTLabels *test_labels = load_mnist_labels(argv[4]);
    
    // Check for consistency.
    if (train_images->num_images != train_labels->num_labels) {
        fprintf(stderr, "Training images and labels count do not match!\n");
        exit(1);
    }
    if (test_images->num_images != test_labels->num_labels) {
        fprintf(stderr, "Test images and labels count do not match!\n");
        exit(1);
    }
    
    int num_train = train_images->num_images;
    int num_test  = test_images->num_images;
    int image_size = train_images->rows * train_images->cols;
    
    printf("Training set: %d images\n", num_train);
    printf("Test set: %d images\n", num_test);
    
    // Print the number of threads that will be used. Playing around w/ parallelism 
    printf("Using %d threads for parallel computation.\n", omp_get_max_threads());
    
    int correct = 0;
    int *predictions = (int *)malloc(num_test * sizeof(int));
    if (!predictions) {
        fprintf(stderr, "Unable to allocate memory for predictions\n");
        exit(1);
    }

    // Measure both CPU time and real (wall-clock) time.
    clock_t cpu_start = clock();
    double wall_start = omp_get_wtime();
    
    // Parallelized classification loop using fixed-point (integer) arithmetic.
    #pragma omp parallel for reduction(+:correct)
    for (int t = 0; t < num_test; t++) {
        // Use unsigned int for fixed-point distances.
        unsigned int best_distances[K];
        int best_indices[K];
        for (int j = 0; j < K; j++) {
            best_distances[j] = UINT_MAX;  // Initialize with maximum possible value.
            best_indices[j] = -1;
        }
        
        unsigned char *test_img = test_images->data + t * image_size;
        for (int i = 0; i < num_train; i++) {
            unsigned char *train_img = train_images->data + i * image_size;
            unsigned int dist = 0;  // Fixed-point accumulated distance.
            for (int p = 0; p < image_size; p++) {
                int diff = (int)test_img[p] - (int)train_img[p];
                dist += diff * diff;
            }
            int max_idx = 0;
            for (int j = 1; j < K; j++) {
                if (best_distances[j] > best_distances[max_idx])
                    max_idx = j;
            }
            if (dist < best_distances[max_idx]) {
                best_distances[max_idx] = dist;
                best_indices[max_idx] = i;
            }
        }
        
        int votes[10] = {0};
        for (int j = 0; j < K; j++) {
            if (best_indices[j] != -1) {
                int label = (int)train_labels->data[best_indices[j]];
                votes[label]++;
            }
        }
        int predicted = 0;
        int max_votes = votes[0];
        for (int d = 1; d < 10; d++) {
            if (votes[d] > max_votes) {
                max_votes = votes[d];
                predicted = d;
            }
        }
        predictions[t] = predicted;
        if (predicted == (int)test_labels->data[t]) {
            correct++;
        }
    }
    
    clock_t cpu_end = clock();
    double wall_end = omp_get_wtime();
    
    double cpu_time = (double)(cpu_end - cpu_start) / CLOCKS_PER_SEC;
    double wall_time = wall_end - wall_start;
    
    double accuracy = (double)correct / num_test * 100.0;
    printf("Accuracy: %.2f%% (%d/%d correct)\n", accuracy, correct, num_test);
    printf("CPU Time: %.2f seconds\n", cpu_time);
    printf("Real (Wall-Clock) Time: %.2f seconds\n", wall_time);
    
    // Visualize 5 random images if -v flag used. 
    if (visualize) {
        int num_to_visualize = 5;  
        if (num_to_visualize > num_test) num_to_visualize = num_test;
        
        for (int i = 0; i < num_to_visualize; i++) {
            int random_index = rand() % num_test;
            printf("\n--- Random Test Image #%d ---\n", random_index);
            printf("Predicted: %d, True: %d\n", predictions[random_index], (int)test_labels->data[random_index]);
            print_image(test_images->data + random_index * image_size, test_images->rows, test_images->cols);
        }
    }
    
    // Free allocated memory.
    free(train_images->data);
    free(train_images);
    free(train_labels->data);
    free(train_labels);
    free(test_images->data);
    free(test_images);
    free(test_labels->data);
    free(test_labels);
    free(predictions);
    
    return 0;
}

// Notes:
// Everything in unsigned fixed-point
// Figure out input data format and how it's going to be retrieved. 
// Cannot use allocated mempry for HLS. Need to be static. 
// Smaller subset needed for BRAM