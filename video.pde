class Video extends MediaObject {
  Movie video;

  Video(String filename, int posX, int posY, boolean h) {
    video = new Movie(main_app, filename);
    video.loop();
    targetX = x = posX;
    targetY = y = posY;
    width = video.width;
    height = video.height;
    hidden = h;
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

  Movie getMovie() {
    return video;
  }
  
  @Override
  void draw(PApplet app) {
    int dx = targetX - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    int dy = targetY - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    if (!hidden) {
      app.image(video, x, y, width*currentScale, height*currentScale);
    }
  }
};
