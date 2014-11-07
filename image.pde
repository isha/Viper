class Image {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;
  int numUpdatesLeft;
  int updateMagnitude;
  long timeOfLastUpdate;
  long intervalTime;
  int updateFlag;

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

    numUpdatesLeft = 0;
    updateMagnitude = 0;
    timeOfLastUpdate = 0;
    intervalTime = 0;
    updateFlag = 0;
  }

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  void startBrightness(int totalMagnitude, int totalUpdateTime, int numUpdates) {
    // save numUpdates in numUpdatesLeft
    numUpdatesLeft = numUpdates;

    // find the intervalTime: intervalTime = totalUpdateTime/numUpdates
    intervalTime = totalUpdateTime/numUpdates;

    // divide magnitude of change by number of updates: updateMagnitude = totalMagnitude/numUpdates
    updateMagnitude = totalMagnitude/numUpdates;

    // set updateFlag to 1;
    updateFlag = 1;
  }

  // at every draw, find difference of currentTime with timeOfLastUpdate = timeElapsedSinceLastUpdate
  // if timeElapsedSinceLastUpdate is greater than intervalTime AND numUpdatesLeft > 0
    // update brightness (setBrightness)
    // change the timeOfLastUpdate = 0
    // reduce numUpdatesLeft by 1
  // else if numUpdatesLeft = 0
    // set updateFlag to 0

  // new image variables:
    // int numUpdatesLeft
    // long timeOfLastUpdate
    // long intervalTime
    // int updateMagnitude

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
          magnitude = constrain(magnitude, 0, 255);

          // Make a new color and set pixel in the window
          color c = color(r, g, b, magnitude);

          picture.pixels[loc] = c;
          picture.updatePixels();
        }
      }
    }
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

    if (updateFlag == 1) {
        if ((System.currentTimeMillis() - timeOfLastUpdate > intervalTime) && (numUpdatesLeft > 0) ) {
          setBrightness(updateMagnitude);
          timeOfLastUpdate = System.currentTimeMillis();
          numUpdatesLeft--;
        }
        else if (numUpdatesLeft == 0) {
          updateFlag = 0;
        }
      }

    image(picture, x, y);
  }

  int getUpdateFlag() {
    return updateFlag;
  }

  long getIntervalTime() {
    return intervalTime;
  }

  int getUpdateMagnitude() {
    return updateMagnitude;
  }

  long getTimeOfLastUpdate() {
    return timeOfLastUpdate;
  }

  int getNumUpdatesLeft() {
    return numUpdatesLeft;
  }

  void setTimeOfLastUpdate(long time_value) {
    timeOfLastUpdate = time_value;
  }

  void setNumUpdatesLeft(int updatesLeft) {
    numUpdatesLeft = updatesLeft;
  }

  void setUpdateFlag(int flag) {
    updateFlag = flag;
  }

};
