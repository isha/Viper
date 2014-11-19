class AnimatedGif {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;
  float currentScale = 1.0;

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

  void startBrightness(int magnitude, int totaltime, int numupdates) {
    for (int i=0; i<frames.length; i++) {
      frames[i].startBrightness(magnitude, totaltime, numupdates);
    }
  }

  void startTransparency(int magnitude, int totaltime, int numupdates) {
    for (int i=0; i<frames.length; i++) {
      frames[i].startTransparency(magnitude, totaltime, numupdates);
    }
  }

  void setTransparency(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setTransparency(magnitude);
    }
  }

  void setRed(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setRed(magnitude);
    }    
  }

  void setGreen(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setGreen(magnitude);
    }    
  }

  void setBlue(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setBlue(magnitude);
    }    
  }

  void setBrightness(int magnitude) {
    for (int i=0; i<frames.length; i++) {
      frames[i].setBrightness(magnitude);
    }        
  }

  void startHue(int dR, int dG, int dB, int totaltime, int numupdates) {
    for (int i=0; i<frames.length; i++) {
      frames[i].startHue(dR, dG, dB, totaltime, numupdates);
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

  Gif getGif() {
    return picture;
  }

  void setScale(int s) {
    currentScale = (float) s/100.0;
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

    for (int i=0; i<frames.length; i++) {
      frames[i].applyEffects();
    }

    image(picture, x, y, picture.width*currentScale, picture.height*currentScale);
  }
};
