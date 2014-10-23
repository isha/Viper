import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

// Constants
static final int FRAMERATE = 2;
static final boolean TESTMODE = true;

TestChannel testChannel;

void setup() {

  if (TESTMODE) {
    testChannel = new TestChannel("sampleEasingInstructions.json", "ocean.jpg");
  } else {
    size(1000, 600);
  }

}

void draw() {

  if (TESTMODE) {
    if (frameCount % FRAMERATE == 0) {
      testChannel.draw();
    }
  }

}

