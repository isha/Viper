class MediaObject {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;
  float speed;
  float currentScale = 1.0;
  float width, height;
  boolean hidden;

  void setEasing(float e) {
    easing = e;
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  void updateSize(float w, float h) {
    width = w;
    height = h;
  }

  void setScale(int s) {
    currentScale = (float) s/100.0;
  }


  void setHidden(boolean h) {
    hidden = h;
  }
  
  void draw(PApplet app) {
  }
};
