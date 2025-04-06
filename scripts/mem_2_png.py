from PIL import Image

def hex_to_rgb(hex_value):
    """Convert a 24-bit hex value to an (R, G, B) tuple."""
    #if(1):
    #    intensity = float(int(hex_value, 16))
    #    intensity = intensity/(2**8)
    #    intensity = intensity*(28)/720
    #    intensity = int(intensity) % 256
    #    return (intensity, intensity, intensity)
        
    hex_value = hex_value.strip().lstrip("#")
    return tuple(int(hex_value[i:i+2], 16) for i in (0, 2, 4))

def text_to_image(text_file, width, height, output_image):
    """Read a text file of hex color values and create a PNG image."""
    with open(text_file, "r") as file:
        hex_values = [line.strip() for line in file.readlines()]

    hex_values_new = []
    for j in hex_values:
        if(j != "xxxxxx"):
            hex_values_new.append(j)
    hex_values = hex_values_new
    print(len(hex_values))    
     
    # Ensure the number of pixels matches width * height
    if len(hex_values) != width * height:
        raise ValueError("Incorrect number of pixels for specified dimensions.")
    
    # Create an image
    img = Image.new("RGB", (width, height))
    pixels = [hex_to_rgb(hex_value) for hex_value in hex_values]
    img.putdata(pixels)
    
    # Save the image
    img.save(output_image)
    print(f"Image saved as {output_image}")

'''
for i in [2, 3, 4, 5, 6]:
    # Example usage
    text_file = f"../dv/ouput_image{i}.mem"  # Replace with your text file path
    width, height = 28, 28  # Set the desired dimensions
    output_image = f"../dv/output_image{i}.png"
    text_to_image(text_file, width, height, output_image)
'''

# Example usage
text_file = f"../dv/saved.mem"  # Replace with your text file path
width, height = 28, 28  # Set the desired dimensions
output_image = f"../dv/saved.png"
text_to_image(text_file, width, height, output_image)