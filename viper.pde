PImage dog;

void setup() {
  dog = loadImage("snowball.jpg")
}


class MediaUnit {
  float ypos, speed;
  HLine (float y, float s) {
    ypos = y;
    speed = s;
  }
  void update() {
    ypos += speed;
    if (ypos > height) {
      ypos = 0;
    }
    line(0, ypos, width, ypos);
  }
