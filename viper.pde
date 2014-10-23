import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

static final int FRAMERATE = 2;

// Sample instructions
JSONObject instr;
JSONArray instructions;
Integer instructionCounter = 0;

// Image list
Hashtable<Integer, Image> images = new Hashtable<Integer, Image>();
Integer imagesCount = 0;

// Background image
PImage backImage;

// Blur variable
float v = 1.0 / 9.0;
float[][] kernel = {{ v, v, v }, 
                    { v, v, v }, 
                    { v, v, v }};

void setup() {
  backImage = loadImage("ocean.jpg");
  size(backImage.width, backImage.height);

  instructions = loadJSONArray("sampleBlurInstructions.json");
}

void draw() {
  if (frameCount % FRAMERATE == 0) {
    image(backImage, 0, 0);

    // Get instruction
    if (instructionCounter < instructions.size()) {
      instr = instructions.getJSONObject(instructionCounter++);
    }

    // Run instruction
    if (instr.getString("Method").equals("create")) {
      Image img = new Image(instr.getString("Image"), instr.getInt("PositionX"), instr.getInt("PositionY"));

      images.put(imagesCount, img);
      imagesCount++;
    }
    else if (instr.getString("Method").equals("update")) {
      Image img = images.get(instr.getInt("Image"));

      if (instr.getString("Action").equals("position")) {
        img.updatePostion(instr.getInt("PositionX"), instr.getInt("PositionY"));
      }
      else if (instr.getString("Action").equals("resize")) {
        img.updateSize(instr.getInt("Width"), instr.getInt("Height"));
      }
      else if (instr.getString("Action").equals("blur")) {
        img.blur(instr.getInt("Magnitude"));
      }
    }
    else if (instr.getString("Method").equals("delete")) {
      images.remove(instr.getInt("Image"));
    }

    // Draw all images
    for (int i=0; i<images.size(); i++) {
      images.get(i).draw();
    }
  }
}

class Image {
  int x, y;
  PImage picture;

  Image(String filename, int posX, int posY) {
    picture = loadImage(filename);
    x = posX;
    y = posY;
  }

  void updatePostion(int posX, int posY) {
    x = posX;
    y = posY;
  }

  void updateSize(int w, int h) {
    picture.resize(w, h);
  }

  void draw() {
    image(picture, x, y);
  }

  void blur(int magnitude) {

    int blur_count = 0;
    
    while (blur_count < magnitude) {

      // Loop through every pixel in the image
      for (int y2 = 1; y2 < picture.height-1; y2++) {   // Skip top and bottom edges
        for (int x2 = 1; x2 < picture.width-1; x2++) {  // Skip left and right edges

          float sum_red = 0; // Kernel sum for this pixel
          float sum_green = 0;
          float sum_blue = 0;

          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {

              // Calculate the adjacent pixel for this kernel point
              int pos = (y2 + ky)*picture.width + (x2 + kx);

              // Compute RGB values
              float val_red = red(picture.pixels[pos]);
              float val_green = green(picture.pixels[pos]);
              float val_blue = blue(picture.pixels[pos]);

              // Multiply adjacent pixels based on the kernel values
              sum_red += kernel[ky+1][kx+1] * val_red;
              sum_green += kernel[ky+1][kx+1] * val_green;
              sum_blue += kernel[ky+1][kx+1] * val_blue;

            }
          }
          // For this pixel in the new image, set the RGB value
          // based on the sum from the kernel
          picture.pixels[y2*picture.width + x2] = color(sum_red, sum_green, sum_blue);
        }
      }

    blur_count++;
    }

    // State that there are changes to edgeImg.pixels[]
    picture.updatePixels();
    
  }
};
