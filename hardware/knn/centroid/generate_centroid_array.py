import idx2numpy
import numpy as np
from sklearn.cluster import KMeans

# Set parameters.
NUM_CENTROIDS = 1    # number of centroids per class
NUM_CLASSES = 10
IMAGE_SIZE = 784     # 28x28 images

# Filenames (adjust paths if needed)
TRAIN_IMAGES_FILE = 'archive/train-images.idx3-ubyte'
TRAIN_LABELS_FILE = 'archive/train-labels.idx1-ubyte'

# Load the training images and labels.
print("Loading training images...")
train_images = idx2numpy.convert_from_file(TRAIN_IMAGES_FILE)
print("Loading training labels...")
train_labels = idx2numpy.convert_from_file(TRAIN_LABELS_FILE)

# Ensure images are flattened (each image is a vector of length IMAGE_SIZE).
num_images, rows, cols = train_images.shape
train_images = train_images.reshape((num_images, -1))

# Dictionary to hold centroids for each class.
centroids = {}

# For each digit class, run k-means clustering to compute NUM_CENTROIDS centroids.
for c in range(NUM_CLASSES):
    # Select all images with label c.
    class_indices = np.where(train_labels == c)[0]
    class_images = train_images[class_indices]
    if class_images.shape[0] == 0:
        # If no samples for a class (unlikely for MNIST), set centroid to mid-gray.
        centroids[c] = np.full((NUM_CENTROIDS, IMAGE_SIZE), 128, dtype=np.uint8)
        continue
    # Run k-means clustering.
    kmeans = KMeans(n_clusters=NUM_CENTROIDS, random_state=0)
    kmeans.fit(class_images)
    # Convert cluster centers to unsigned 8-bit integers (values in [0,255]).
    centers = np.clip(np.rint(kmeans.cluster_centers_), 0, 255).astype(np.uint8)
    centroids[c] = centers

# Print the centroids in a C initializer format.
print("static const unsigned char centroids[NUM_CLASSES][NUM_CENTROIDS][IMAGE_SIZE] = {")
for c in range(NUM_CLASSES):
    print("    {{   // Class {}".format(c))
    for m in range(NUM_CENTROIDS):
        # Create a comma-separated string of pixel values.
        pixel_values = ", ".join(str(int(val)) for val in centroids[c][m])
        print("        { " + pixel_values + " },")
    print("    },")
print("};")
