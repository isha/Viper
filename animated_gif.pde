class AnimatedGif {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;

  Gif picture;
  Image[] frames; 

  AnimatedGif(String filename, int posX, int posY) {
    Gif myAnimation = new Gif(app, filename);
    myAnimation.play();
    picture = myAnimation;

    targetX = x = posX;
    targetY = y = posY;

    PImage[] images = picture.getPImages();
    frames = new Image[images.length];

    for (int i=0; i<images.length; i++) {
      frames[i] = new Image(images[i]);
    }
  }

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  void setBrightness(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setBrightness(magnitude);
    }
  }

  void setTransparency(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setTransparency(magnitude);
    }
  }

  void adjustHue(int dR, int dG, int dB) {
    for (int i=0; i<frames.length; i++) {
      frames[i].adjustHue(dR, dG, dB);
    }
  }

  void blur(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].blur(magnitude);
    }
  }

  void gray() {
    for (int i=0; i<frames.length; i++) {
      frames[i].gray();
    }
  }

  void invert() {
    for (int i=0; i<frames.length; i++) {
      frames[i].invert();
    }
  }

  void posterize(int numColours) {
    for (int i=0; i<frames.length; i++) {
      frames[i].posterize(numColours);
    }
  }

  void erode() {
    for (int i=0; i<frames.length; i++) {
      frames[i].erode();
    }
  }

  void dilate() {
    for (int i=0; i<frames.length; i++) {
      frames[i].dilate();
    }
  }

  void threshold(float thresholdValue) {
    for (int i=0; i<frames.length; i++) {
      frames[i].threshold(thresholdValue);
    }
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
