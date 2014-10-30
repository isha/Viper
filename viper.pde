import java.util.Map;
import java.util.Hashtable;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;


static final boolean TESTMODE = true;

PApplet app;

Channel channel;
OSCServer oscServer;

void setup() {
  app = this;
  ConcurrentLinkedQueue<JSONObject> queue = new ConcurrentLinkedQueue<JSONObject>();

  if (TESTMODE) {
    Thread instructionReader = new Thread(new InstructionReader(queue, "sampleGifInstructions.json"));
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

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}


