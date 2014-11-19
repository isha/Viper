class Video {
  int x, y;
  int targetX, targetY;
  float easing = 0.1;
  float speed;
  int currentScale = 100;

  Movie video;

  Video(String filename, int posX, int posY) {
    video = new Movie(app, filename);
    video.loop();
    targetX = x = posX;
    targetY = y = posY;
  }

  void setEasing(float e) {
    easing = e;
  }

  void setPlaybackSpeed(float s) {
    speed = Math.abs(s);
  }

  void setReversePlaybackSpeed() {
    speed = -1 * speed;
  }

  void updatePlaybackSpeed() {
    video.speed(speed);
  }

  void updateTargetPostion(int posX, int posY) {
    targetX = posX;
    targetY = posY;
  }

  Movie getMovie() {
    return video;
  }

  void setScale(int s) {
    currentScale = s;
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

    image(video, x, y, video.width*(currentScale/100), video.height*(currentScale/100));
  }
};
