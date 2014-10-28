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
