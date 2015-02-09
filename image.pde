class Image extends MediaObject {
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
  long[] totalTransitionTime;
  long[] startTransitionTime;

  boolean rotateFlag;

  PImage picture;
  PImage originalPicture;

  Image(String filename, float posX, float posY, boolean h) {
    picture = loadImage(filename);
    originalPicture = loadImage(filename);
    
    targetX = constrain(posX, 0, 1); 
    targetY = constrain(posY, 0, 1);
    x = targetX*WIDTH;
    y = targetY*HEIGHT;
    hidden = h;

    numUpdatesLeft = new int[NUM_TRANSITIONS];
    updateMagnitude = new int[NUM_TRANSITIONS];
    timeOfLastUpdate = new long[NUM_TRANSITIONS];
    intervalTime = new long[NUM_TRANSITIONS];
    updateFlag = new boolean[NUM_TRANSITIONS];
    totalTransitionTime = new long[NUM_TRANSITIONS];
    startTransitionTime = new long[NUM_TRANSITIONS];

    degsToRotate = 0;

    width = (float) picture.width/WIDTH;
    height = (float) picture.height/HEIGHT;
  }

  Image(PImage pic) {
    picture = pic;
    originalPicture = new PImage();
    originalPicture.copy(pic, 0, 0, pic.width, pic.height, 0, 0, pic.width, pic.height);

    numUpdatesLeft = new int[NUM_TRANSITIONS];
    updateMagnitude = new int[NUM_TRANSITIONS];
    timeOfLastUpdate = new long[NUM_TRANSITIONS];
    intervalTime = new long[NUM_TRANSITIONS];
    updateFlag = new boolean[NUM_TRANSITIONS];
    totalTransitionTime = new long[NUM_TRANSITIONS];
    startTransitionTime = new long[NUM_TRANSITIONS];

    degsToRotate = 0;
  }

  void startBrightness(int totalMagnitude, int totalUpdateTime, int numUpdates) {

    numUpdatesLeft[BRIGHTNESS_VALUE] = numUpdates;
    intervalTime[BRIGHTNESS_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[BRIGHTNESS_VALUE] = totalMagnitude/numUpdates;
    updateFlag[BRIGHTNESS_VALUE] = true;
    totalTransitionTime[BRIGHTNESS_VALUE] = totalUpdateTime;
    startTransitionTime[BRIGHTNESS_VALUE] = System.currentTimeMillis();
  }

  void adjustBrightness(int magnitude) {
    picture.loadPixels();

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

          picture.pixels[loc] = c;
        }
      }
    }

    picture.updatePixels();
  }

  void startTransparency(int totalMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[TRANSPARENCY_VALUE] = numUpdates;
    intervalTime[TRANSPARENCY_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[TRANSPARENCY_VALUE] = totalMagnitude/numUpdates;
    updateFlag[TRANSPARENCY_VALUE] = true;
    totalTransitionTime[TRANSPARENCY_VALUE] = totalUpdateTime;
    startTransitionTime[TRANSPARENCY_VALUE] = System.currentTimeMillis();
  }

  void adjustTransparency(int magnitude) {
    picture.loadPixels();

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
        }
      }
    }
    picture.updatePixels();
  }

  void startHue (int totalRedMagnitude, int totalGreenMagnitude, int totalBlueMagnitude, int totalUpdateTime, int numUpdates) {
    if (totalRedMagnitude != 0) { startRedHue(totalRedMagnitude, totalUpdateTime, numUpdates); }
    if (totalGreenMagnitude != 0) { startGreenHue(totalGreenMagnitude, totalUpdateTime, numUpdates); }
    if (totalBlueMagnitude != 0) { startBlueHue(totalBlueMagnitude, totalUpdateTime, numUpdates); }
  }

  void startRedHue (int totalRedMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[RED_VALUE] = numUpdates;
    intervalTime[RED_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[RED_VALUE] = totalRedMagnitude/numUpdates;
    updateFlag[RED_VALUE] = true;
    totalTransitionTime[RED_VALUE] = totalUpdateTime;
    startTransitionTime[RED_VALUE] = System.currentTimeMillis();
  }

  void startGreenHue (int totalGreenMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[GREEN_VALUE] = numUpdates;
    intervalTime[GREEN_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[GREEN_VALUE] = totalGreenMagnitude/numUpdates;
    updateFlag[GREEN_VALUE] = true;
    totalTransitionTime[GREEN_VALUE] = totalUpdateTime;
    startTransitionTime[GREEN_VALUE] = System.currentTimeMillis();
  }

  void startBlueHue (int totalBlueMagnitude, int totalUpdateTime, int numUpdates) {
    numUpdatesLeft[BLUE_VALUE] = numUpdates;
    intervalTime[BLUE_VALUE] = totalUpdateTime/numUpdates;
    updateMagnitude[BLUE_VALUE] = totalBlueMagnitude/numUpdates;
    updateFlag[BLUE_VALUE] = true;
    totalTransitionTime[BLUE_VALUE] = totalUpdateTime;
    startTransitionTime[BLUE_VALUE] = System.currentTimeMillis();
  }  

  void adjustRedHue (int magnitude) {
    picture.loadPixels();

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

          picture.pixels[loc] = c;
          
        }
      }
    }
    picture.updatePixels();
  }

  void adjustGreenHue (int magnitude) {
    picture.loadPixels();

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

          picture.pixels[loc] = c;
          
        }
      }
    }
    picture.updatePixels();
  }

  void adjustBlueHue (int magnitude) {
    picture.loadPixels();

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

          picture.pixels[loc] = c;
          
        }
      }
    }
    picture.updatePixels();
  }

  void setTransparency(int magnitude) {
    picture.loadPixels();

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
        
        }
      }
    }
    picture.updatePixels();
  }

  void setRed(int magnitude) {
    picture.loadPixels();

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
          
        }
      }
    }
    picture.updatePixels();    
  }

  void setGreen(int magnitude) {
    picture.loadPixels();

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
          
        }
      }
    }
    picture.updatePixels();    
  }

  void setBlue(int magnitude) {
    picture.loadPixels();

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
          
        }
      }
    }
    picture.updatePixels();    
  }

  void setBrightness(int magnitude) {
    picture.loadPixels();
    
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
          
        }
      }
    }
    picture.updatePixels();    
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

  void setRotation(int degs) {
    degsToRotate = degs;
  }

  void applyEffects() {
    // iterate through all possible effects 
    for (int i = 0; i < NUM_TRANSITIONS; i++) {

      long transitionTimeElapsed = System.currentTimeMillis() - startTransitionTime[i];
      long timeSinceLastUpdate = System.currentTimeMillis() - timeOfLastUpdate[i];

      if (updateFlag[i] == true) {
        if ( timeSinceLastUpdate > intervalTime[i] && numUpdatesLeft[i] > 0 && transitionTimeElapsed < totalTransitionTime[i]) {

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
      if ( (numUpdatesLeft[i] == 0 || transitionTimeElapsed >= totalTransitionTime[i] ) && updateFlag[i] == true) {
        updateFlag[i] = false;
        updateMagnitude[i] = 0;
        numUpdatesLeft[i] = 0;
        intervalTime[i] = 0;
        totalTransitionTime[i] = 0;
        startTransitionTime[i] = 0;
      }

    }
  }

  void applyRotate(PApplet app) {
    // shift origin of coordinate system to the center of the image being rotated
    app.translate(x + (width*currentScale)/2, y + (height*currentScale)/2);

    // rotate the image
    app.rotate(radians(degsToRotate));

    // revert coordinate system back
    app.translate(-x - (width*currentScale)/2, - y - (height*currentScale)/2);
  }

  PImage getPImage() {
    return picture;
  }

  void reset() {
    picture.copy(originalPicture, 0, 0, originalPicture.width, originalPicture.height, 0, 0, originalPicture.width, originalPicture.height);
  }

  @Override
  void draw(PApplet app) {
    float dx = targetX*WIDTH - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    float dy = targetY*HEIGHT - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    applyEffects();

    app.pushMatrix();
    applyRotate(app);  
    
    if (!hidden) {
      app.image(picture, x, y, width*WIDTH*currentScale, height*HEIGHT*currentScale);
    }
    
    app.popMatrix();    
  }

};
