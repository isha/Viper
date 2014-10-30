import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

static final boolean TESTMODE = true;

TestChannel testChannel;
OSCServer oscServer;

void setup() {
  if (TESTMODE) {
    testChannel = new TestChannel("sampleEasingInstructions.json", "ocean.jpg");
  } else {
    oscServer = new OSCServer();
  }
}

void draw() {
  if (TESTMODE) {
    testChannel.draw();
  }
}

void mousePressed() {
  oscServer.mousePressed();
}
