from PIL import Image
import os

def pad_logo(input_path, output_path, scale_factor=0.7):
    # Load the logo
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    # Calculate new dimensions for the centered logo
    new_width = int(width * scale_factor)
    new_height = int(height * scale_factor)
    
    # Resize the logo
    scaled_logo = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Create a new transparent canvas of the original size
    new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    
    # Center the scaled logo on the new canvas
    offset = ((width - new_width) // 2, (height - new_height) // 2)
    new_img.paste(scaled_logo, offset, scaled_logo)
    
    # Save the result
    new_img.save(output_path)
    print(f"Padded logo saved to {output_path}")

if __name__ == "__main__":
    logo_path = "assets/images/app_logo.png"
    # We'll overwrite it to make it easy for flutter_launcher_icons
    pad_logo(logo_path, logo_path)
