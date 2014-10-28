import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

static final boolean TESTMODE = true;

TestChannel testChannel;
OSCServer oscServer;

void setup() {

  if (TESTMODE) {
    oscServer = new OSCServer();
    testChannel = new TestChannel("sampleFilterInstructions.json", "ocean.jpg");
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
