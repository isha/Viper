class MediaObject {
  float x, y;
  float targetX, targetY;
  float easing = 0.1;
  float currentScale = 1.0;
  float width, height;
  boolean hidden;

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(float posX, float posY) {
    targetX = constrain(posX, 0, 1);
    targetY = constrain(posY, 0, 1);
  }

  void updateSize(float w, float h) {
    width = constrain(w, 0, 1);
    height = constrain(h, 0, 1);
  }

  void setScale(int s) {
    currentScale = (float) s/100.0;
  }


  void setHidden(boolean h) {
    hidden = h;
  }
  
  void draw() {
  }
};
