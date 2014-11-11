class Image {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;

  // image effect transition variables
  private static final int BRIGHTNESS_VALUE = 0;
  private static final int TRANSPARENCY_VALUE = 1;
  private static final int RED_VALUE = 2;
  private static final int GREEN_VALUE = 3;
  private static final int BLUE_VALUE = 4;
  private static final int BLUR_VALUE = 5;
  private static final int NUM_TRANSITIONS = 6;

  int[] numUpdatesLeft;
  int[] updateMagnitude;
  long[] timeOfLastUpdate;
  long[] intervalTime;
  int[] updateFlag;

  PImage picture;

  Image(String filename, int posX, int posY) {
    if (filename.endsWith(".gif")) {
      Gif myAnimation = new Gif(app, filename);
      myAnimation.play();
      picture = myAnimation;
    } else {
      picture = loadImage(filename);
    }
    targetX = x = posX;
    targetY = y = posY;

    numUpdatesLeft = new int[NUM_TRANSITIONS];
    updateMagnitude = new int[NUM_TRANSITIONS];
    timeOfLastUpdate = new long[NUM_TRANSITIONS];
    intervalTime = new long[NUM_TRANSITIONS];
    updateFlag = new int[NUM_TRANSITIONS];
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
    updateFlag[BRIGHTNESS_VALUE] = 1;
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
    updateFlag[TRANSPARENCY_VALUE] = 1;
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
          a -= magnitude;
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
    updateFlag[RED_VALUE] = 1;
  }

  void startGreenHue (int totalGreenMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[GREEN_VALUE] = numUpdates;
    intervalTime[GREEN_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[GREEN_VALUE] = totalGreenMagnitude/numUpdates;
    updateFlag[GREEN_VALUE] = 1;
  }

  void startBlueHue (int totalBlueMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[BLUE_VALUE] = numUpdates;
    intervalTime[BLUE_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[BLUE_VALUE] = totalBlueMagnitude/numUpdates;
    updateFlag[BLUE_VALUE] = 1;
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

  void blur(int magnitude) {
    picture.filter(BLUR, magnitude);
  }

  void gray() {
    picture.filter(GRAY);
  }

  void invert() {
    picture.filter(INVERT);
  }

  void posterize(int numColours) {
    picture.filter(POSTERIZE, numColours);
  }

  void erode() {
    picture.filter(ERODE);
  }

  void dilate() {
    picture.filter(DILATE);
  }

  void threshold(float thresholdValue) {
    picture.filter(THRESHOLD, thresholdValue);
  }



  void adjustHue(int dR, int dG, int dB) {
    for (int px = 0; px < picture.width; px++) {
      for (int py = 0; py < picture.height; py++ ) {

        // Calculate the 1D location from a 2D grid
        int loc = px + py*picture.width;

        // check transparency
        if (alpha(picture.pixels[loc]) != 0.0) {

          // Get the R,G,B values from image
          float r,g,b;
          r = red (picture.pixels[loc]) + dR;
          g = green (picture.pixels[loc]) + dG;
          b = blue (picture.pixels[loc]) + dB;

          // Constrain RGB to make sure they are within 0-255 color range
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

    // effect transition checks - put a for loop here to iterate through all effect transitions
    // replace BRIGHTNESS_VALUE with NUM_TRANSITION
    if (updateFlag[BRIGHTNESS_VALUE] == 1) {
      if ((System.currentTimeMillis() - timeOfLastUpdate[BRIGHTNESS_VALUE] > intervalTime[BRIGHTNESS_VALUE]) && (numUpdatesLeft[BRIGHTNESS_VALUE] > 0) ) {
        adjustBrightness(updateMagnitude[BRIGHTNESS_VALUE]);
        timeOfLastUpdate[BRIGHTNESS_VALUE] = System.currentTimeMillis();
        numUpdatesLeft[BRIGHTNESS_VALUE]--;
      }
      else if (numUpdatesLeft[BRIGHTNESS_VALUE] == 0) {
        updateFlag[BRIGHTNESS_VALUE] = 0;
      }
    }

    if (updateFlag[TRANSPARENCY_VALUE] == 1) {
      if ((System.currentTimeMillis() - timeOfLastUpdate[TRANSPARENCY_VALUE] > intervalTime[TRANSPARENCY_VALUE]) && (numUpdatesLeft[TRANSPARENCY_VALUE] > 0) ) {
        adjustTransparency(updateMagnitude[TRANSPARENCY_VALUE]);
        timeOfLastUpdate[TRANSPARENCY_VALUE] = System.currentTimeMillis();
        numUpdatesLeft[TRANSPARENCY_VALUE]--;
      }
      else if (numUpdatesLeft[TRANSPARENCY_VALUE] == 0) {
        updateFlag[TRANSPARENCY_VALUE] = 0;
      }
    }

    if (updateFlag[RED_VALUE] == 1) {
      if ((System.currentTimeMillis() - timeOfLastUpdate[RED_VALUE] > intervalTime[RED_VALUE]) && (numUpdatesLeft[RED_VALUE] > 0) ) {
        adjustRedHue(updateMagnitude[RED_VALUE]);
        timeOfLastUpdate[RED_VALUE] = System.currentTimeMillis();
        numUpdatesLeft[RED_VALUE]--;
      }
      else if (numUpdatesLeft[RED_VALUE] == 0) {
        updateFlag[RED_VALUE] = 0;
      }
    }

    if (updateFlag[GREEN_VALUE] == 1) {
      if ((System.currentTimeMillis() - timeOfLastUpdate[GREEN_VALUE] > intervalTime[GREEN_VALUE]) && (numUpdatesLeft[GREEN_VALUE] > 0) ) {
        adjustGreenHue(updateMagnitude[GREEN_VALUE]);
        timeOfLastUpdate[GREEN_VALUE] = System.currentTimeMillis();
        numUpdatesLeft[GREEN_VALUE]--;
      }
      else if (numUpdatesLeft[GREEN_VALUE] == 0) {
        updateFlag[GREEN_VALUE] = 0;
      }
    }

    if (updateFlag[BLUE_VALUE] == 1) {
      if ((System.currentTimeMillis() - timeOfLastUpdate[BLUE_VALUE] > intervalTime[BLUE_VALUE]) && (numUpdatesLeft[BLUE_VALUE] > 0) ) {
        adjustBlueHue(updateMagnitude[BLUE_VALUE]);
        timeOfLastUpdate[BLUE_VALUE] = System.currentTimeMillis();
        numUpdatesLeft[BLUE_VALUE]--;
      }
      else if (numUpdatesLeft[BLUE_VALUE] == 0) {
        updateFlag[BLUE_VALUE] = 0;
      }
    }

    image(picture, x, y);
  }

};
