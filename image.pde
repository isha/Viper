class Image {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;

  PImage picture;

  Image(String filename, int posX, int posY) {
    picture = loadImage(filename);
    x = posX;
    y = posY;
  }

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  void setBrightness(int magnitude) {

    for (int px = 0; px < picture.width; px++) {
      for (int py = 0; py < picture.height; py++ ) {

        // Calculate the 1D location from a 2D grid
        int loc = px + py*picture.width;

        // check transparency
        if (alpha(picture.pixels[loc]) != 0.0) {
          // Get the R,G,B values from image
          float r,g,b;
          r = red (picture.pixels[loc]);
          g = green (picture.pixels[loc]);
          b = blue (picture.pixels[loc]);

          // Adjust the brightness by adding or subtracting RGB values
          float adjustbrightness = magnitude;
          r += adjustbrightness;
          g += adjustbrightness;
          b += adjustbrightness;

          // Constrain RGB to make sure they are within 0-255 color range
          r = constrain(r, 0, 255);
          g = constrain(g, 0, 255);
          b = constrain(b, 0, 255);
          
          // Make a new color and set pixel in the window
          color c = color(r, g, b);

          //pixels[py*width + px] = c;
          picture.pixels[loc] = c;
          picture.updatePixels();

        }

      }
    }
  }

  void updateSize(int w, int h) {
    picture.resize(w, h);
  }

  void draw() {
    int dx = targetX - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    int dy = targetY - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }
    image(picture, x, y);
  }
};
