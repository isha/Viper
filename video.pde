class Video extends MediaObject {
  Movie video;

  Video(String filename, float posX, float posY, boolean h) {
    video = new Movie(main_app, filename);
    video.loop();
    targetX = x = constrain(posX, 0, 1); 
    targetY = y = constrain(posY, 0, 1);
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
    float dx = targetX - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    float dy = targetY - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    if (!hidden) {
      app.image(video, x, y, width*currentScale, height*currentScale);
    }
  }
};
