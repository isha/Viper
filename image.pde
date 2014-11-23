class Image {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;
  float currentScale = 1.0;
  float width, height;
  int degsToRotate;

  // image effect transition variables
  private static final int BRIGHTNESS_VALUE = 0;
  private static final int TRANSPARENCY_VALUE = 1;
  private static final int RED_VALUE = 2;
  private static final int GREEN_VALUE = 3;
  private static final int BLUE_VALUE = 4;
  private static final int NUM_TRANSITIONS = 5;

  int[] numUpdatesLeft;
  int[] updateMagnitude;
  long[] timeOfLastUpdate;
  long[] intervalTime;
  boolean[] updateFlag;

  boolean rotateFlag;

  PImage picture;
  PImage originalPicture;

  Image(String filename, int posX, int posY) {
    picture = loadImage(filename);
    originalPicture = loadImage(filename);
    
    targetX = x = posX;
    targetY = y = posY;

    numUpdatesLeft = new int[NUM_TRANSITIONS];
    updateMagnitude = new int[NUM_TRANSITIONS];
    timeOfLastUpdate = new long[NUM_TRANSITIONS];
    intervalTime = new long[NUM_TRANSITIONS];
    updateFlag = new boolean[NUM_TRANSITIONS];
    degsToRotate = 0;

    width = picture.width;
    height = picture.height;
  }

  Image(PImage pic) {
    picture = pic;
    originalPicture = pic;

    numUpdatesLeft = new int[NUM_TRANSITIONS];
    updateMagnitude = new int[NUM_TRANSITIONS];
    timeOfLastUpdate = new long[NUM_TRANSITIONS];
    intervalTime = new long[NUM_TRANSITIONS];
    updateFlag = new boolean[NUM_TRANSITIONS];
    degsToRotate = 0;

  }

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  void startBrightness(int totalMagnitude, int totalUpdateTime, int numUpdates) {

    numUpdatesLeft[BRIGHTNESS_VALUE] = numUpdates;
    intervalTime[BRIGHTNESS_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[BRIGHTNESS_VALUE] = totalMagnitude/numUpdates;
    updateFlag[BRIGHTNESS_VALUE] = true;
  }

  void adjustBrightness(int magnitude) {

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
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          //pixels[py*width + px] = c;
          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
  }

  void startTransparency(int totalMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[TRANSPARENCY_VALUE] = numUpdates;
    intervalTime[TRANSPARENCY_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[TRANSPARENCY_VALUE] = totalMagnitude/numUpdates;
    updateFlag[TRANSPARENCY_VALUE] = true;
  }

  void adjustTransparency(int magnitude) {
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

          // get the alpha value
          int a = (int) alpha(picture.pixels[loc]);

          // Constrain alpha value to make sure they are within 1-255 alpha range
          a += magnitude;
          a = constrain(a, 1, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, a);

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
  }

  void startHue (int totalRedMagnitude, int totalGreenMagnitude, int totalBlueMagnitude, int totalUpdateTime, int numUpdates) {
    startRedHue(totalRedMagnitude, totalUpdateTime, numUpdates);
    startGreenHue(totalGreenMagnitude, totalUpdateTime, numUpdates);
    startBlueHue(totalBlueMagnitude, totalUpdateTime, numUpdates);
  }

  void startRedHue (int totalRedMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[RED_VALUE] = numUpdates;
    intervalTime[RED_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[RED_VALUE] = totalRedMagnitude/numUpdates;
    updateFlag[RED_VALUE] = true;
  }

  void startGreenHue (int totalGreenMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[GREEN_VALUE] = numUpdates;
    intervalTime[GREEN_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[GREEN_VALUE] = totalGreenMagnitude/numUpdates;
    updateFlag[GREEN_VALUE] = true;
  }

  void startBlueHue (int totalBlueMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[BLUE_VALUE] = numUpdates;
    intervalTime[BLUE_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[BLUE_VALUE] = totalBlueMagnitude/numUpdates;
    updateFlag[BLUE_VALUE] = true;
  }  

  void adjustRedHue (int magnitude) {
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
          r += magnitude;

          // Constrain RGB to make sure they are within 0-255 color range
          r = constrain(r, 0, 255);
          g = constrain(g, 0, 255);
          b = constrain(b, 0, 255);
          
          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          //pixels[py*width + px] = c;
          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
  }

  void adjustGreenHue (int magnitude) {
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
          g += magnitude;

          // Constrain RGB to make sure they are within 0-255 color range
          r = constrain(r, 0, 255);
          g = constrain(g, 0, 255);
          b = constrain(b, 0, 255);
          
          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          //pixels[py*width + px] = c;
          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
  }

  void adjustBlueHue (int magnitude) {
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
          b += magnitude;

          // Constrain RGB to make sure they are within 0-255 color range
          r = constrain(r, 0, 255);
          g = constrain(g, 0, 255);
          b = constrain(b, 0, 255);
          
          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          //pixels[py*width + px] = c;
          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
  }

  void setTransparency(int magnitude) {
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
 
        // Constrain alpha value to make sure they are within 1-255 alpha range
        magnitude = constrain(magnitude, 1, 255);

        // Make a new color and set pixel in the window
        color c = color(r, g, b, magnitude);

        picture.pixels[loc] = c;
        picture.updatePixels();
        }
      }
    }
  }

  void setRed(int magnitude) {
    for (int px = 0; px < picture.width; px++) {
      for (int py = 0; py < picture.height; py++ ) {

        // Calculate the 1D location from a 2D grid
        int loc = px + py*picture.width;

        // check transparency
        if (alpha(picture.pixels[loc]) != 0.0) {

          // Get the R,G,B values from image
          float r,g,b;
          r = red (originalPicture.pixels[loc]) + magnitude;
          g = green (picture.pixels[loc]);
          b = blue (picture.pixels[loc]);
   
          // Constrain red value to make sure they are within 0-255 alpha range
          r = constrain(r, 0, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }    
  }

  void setGreen(int magnitude) {
    for (int px = 0; px < picture.width; px++) {
      for (int py = 0; py < picture.height; py++ ) {

        // Calculate the 1D location from a 2D grid
        int loc = px + py*picture.width;

        // check transparency
        if (alpha(picture.pixels[loc]) != 0.0) {

          // Get the R,G,B values from image
          float r,g,b;
          r = red (picture.pixels[loc]);
          g = green (originalPicture.pixels[loc]) + magnitude;
          b = blue (picture.pixels[loc]);
   
          // Constrain green value to make sure they are within 0-255 alpha range
          g = constrain(g, 0, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }    
  }

  void setBlue(int magnitude) {
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
          b = blue (originalPicture.pixels[loc]) + magnitude;
   
          // Constrain blue value to make sure they are within 0-255 alpha range
          b = constrain(b, 0, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }    
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
          r = red (originalPicture.pixels[loc]) + magnitude;
          g = green (originalPicture.pixels[loc]) + magnitude;
          b = blue (originalPicture.pixels[loc]) + magnitude;
   
          // Constrain blue value to make sure they are within 0-255 alpha range
          r = constrain(r, 0, 255);
          g = constrain(g, 0, 255);
          b = constrain(b, 0, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, alpha(picture.pixels[loc]));

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }    
  }  

  void blur(int magnitude) {
    int constrainedValue = constrain(magnitude, 1, 5);
    picture.filter(BLUR, constrainedValue);
  }

  void gray() {
    picture.filter(GRAY);
  }

  void invert() {
    picture.filter(INVERT);
  }

  void posterize(int numColours) {
    int constrainedValue = constrain(numColours, 2, 255);
    picture.filter(POSTERIZE, constrainedValue);
  }

  void erode() {
    picture.filter(ERODE);
  }

  void dilate() {
    picture.filter(DILATE);
  }

  void threshold(float thresholdValue) {
    float constrainedValue = constrain(thresholdValue, 0.0, 1.0);
    picture.filter(THRESHOLD, constrainedValue);
  }

  void updateSize(float w, float h) {
    width = w;
    height = h;
  }

  void setScale(int s) {
    currentScale = (float) s/100.0;
  }

  void setRotation(int degs) {
    degsToRotate = degs;
  }

  void applyEffects() {
    // iterate through all possible effects 
    for (int i = 0; i < NUM_TRANSITIONS; i++) {

      if (updateFlag[i] == true) {
        if ((System.currentTimeMillis() - timeOfLastUpdate[i] > intervalTime[i]) && (numUpdatesLeft[i] > 0) ) {

          if (i == BRIGHTNESS_VALUE) 
            { adjustBrightness(updateMagnitude[i]); }
          else if (i == TRANSPARENCY_VALUE) 
            { adjustTransparency(updateMagnitude[i]); }
          else if (i == RED_VALUE) 
            { adjustRedHue(updateMagnitude[i]); }
          else if (i == GREEN_VALUE) 
            { adjustGreenHue(updateMagnitude[i]); }
          else if (i == BLUE_VALUE) 
            { adjustBlueHue(updateMagnitude[i]); }

          timeOfLastUpdate[i] = System.currentTimeMillis();
          numUpdatesLeft[i]--;
        }
      }
      else if (numUpdatesLeft[i] == 0) {
        updateFlag[i] = false;
      }

    }
  }

  void applyRotate(PApplet app) {
    app.pushMatrix();
    // shift origin of coordinate system to the center of the image being rotated
    app.translate(x + (picture.width*currentScale)/2, y + (picture.height*currentScale)/2);

    // rotate the image
    app.rotate(radians(degsToRotate));

    // revert coordinate system back
    app.translate(-x - (picture.width*currentScale)/2, - y - (picture.height*currentScale)/2);
    
    app.popMatrix();
  }

  PImage getPImage() {
    return picture;
  }

  void draw(PApplet app) {
    int dx = targetX - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    int dy = targetY - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    applyEffects();
    applyRotate(app);

    app.image(picture, x, y, width*currentScale, height*currentScale);  
  }

};
