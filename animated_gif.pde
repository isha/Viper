class AnimatedGif extends MediaObject {
  Gif picture;
  Image[] frames; 

  AnimatedGif(String filename, float posX, float posY, boolean h) {
    Gif myAnimation = new Gif(main_app, filename);
    myAnimation.play();
    myAnimation.loop();
    picture = myAnimation;

    targetX = constrain(posX, 0, 1); 
    targetY = constrain(posY, 0, 1);
    x = targetX*WIDTH;
    y = targetY*HEIGHT;

    hidden = h;

    PImage[] images = picture.getPImages();
    frames = new Image[images.length];

    for (int i=0; i<images.length; i++) {
      frames[i] = new Image(images[i]);
    }

    width = (float) picture.width/WIDTH;
    height = (float) picture.height/HEIGHT;
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

  void draw() {
    float dx = targetX*WIDTH - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    float dy = targetY*HEIGHT - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    for (int i=0; i<frames.length; i++) {
      frames[i].applyEffects();
    }

    if (!hidden) {
      image(picture, x, y, width*WIDTH*currentScale, height*HEIGHT*currentScale);
    }
  }
};
