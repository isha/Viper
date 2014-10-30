import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;

static final boolean TESTMODE = true;

Channel channel;
OSCServer oscServer;

void setup() {
  ConcurrentLinkedQueue<JSONObject> queue = new ConcurrentLinkedQueue<JSONObject>();

  if (TESTMODE) {
    Thread instructionReader = new Thread(new InstructionReader(queue, "sampleEasingInstructions.json"));
    instructionReader.start();
  } else {
    oscServer = new OSCServer();
  }

  channel = new Channel(queue, "ocean.jpg");
}

void draw() {
  channel.draw();
}

void mousePressed() {
  if (!TESTMODE) {
    oscServer.mousePressed();
  }
}
