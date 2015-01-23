class AnimatedGif {
  float x, y;
  float targetX, targetY;
  float easing = 0.1;
  float currentScale = 1.0;
  float width, height;
  boolean hidden;

  Gif picture;
  Image[] frames; 

  AnimatedGif(String filename, float posX, float posY, boolean h) {
    Gif myAnimation = new Gif(main_app, filename);
    myAnimation.play();
    picture = myAnimation;

    targetX = x = WIDTH*constrain(posX, 0, 1); 
    targetY = y = HEIGHT*constrain(posY, 0, 1);
    hidden = h;

    PImage[] images = picture.getPImages();
    frames = new Image[images.length];

    for (int i=0; i<images.length; i++) {
      frames[i] = new Image(images[i]);
    }

    width = picture.width;
    height = picture.height;
  }

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(float posX, float posY) {
    targetX = WIDTH*constrain(posX, 0, 1);
    targetY = HEIGHT*constrain(posY, 0, 1);
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

  void updateSize(float w, float h) {
    width = WIDTH*constrain(w, 0, 1);
    height = HEIGHT*constrain(h, 0, 1);
  }

  void setHidden(boolean h) {
    hidden = h;
  }

  void draw(PApplet app) {
    float dx = targetX - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    float dy = targetY - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    for (int i=0; i<frames.length; i++) {
      frames[i].applyEffects();
    }

    if (!hidden) {
      app.image(picture, x, y, width*currentScale, height*currentScale);
    }
  }
};
