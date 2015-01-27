class Video extends MediaObject {
  Movie video;

  Video(String filename, float posX, float posY, boolean h) {
    video = new Movie(main_app, filename);
    video.loop();
    targetX = constrain(posX, 0, 1); 
    targetY = constrain(posY, 0, 1);
    x = targetX*WIDTH;
    y = targetY*HEIGHT;
    width = (float) video.width/WIDTH;
    height = (float) video.height/HEIGHT;
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
    float dx = targetX*WIDTH - x;
    if(abs(dx) > 1) {
      x += dx * easing;
    }

    float dy = targetY*HEIGHT - y;
    if(abs(dy) > 1) {
      y += dy * easing;
    }

    if (!hidden) {
      app.image(video, x, y, width*WIDTH*currentScale, height*HEIGHT*currentScale);
    }
  }
};
