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

Hashtable<Integer, Channel> channels;
Hashtable<Integer, ConcurrentLinkedQueue<JSONObject>> queues;

OSCServer oscServer;

void setup() {
  app = this;
  channels = new Hashtable<Integer, Channel>();
  queues = new Hashtable<Integer, ConcurrentLinkedQueue<JSONObject>>();

  if (TESTMODE) {
    ConcurrentLinkedQueue<JSONObject> queue1 = addChannel(1);
    Thread instructionReader1 = new Thread(new InstructionReader(queue1, "sampleGifInstructions.json"));
    instructionReader1.start();

    ConcurrentLinkedQueue<JSONObject> queue2 = addChannel(2);
    Thread instructionReader2 = new Thread(new InstructionReader(queue2, "sampleFilterInstructions.json"));
    instructionReader2.start();
  } else {
    oscServer = new OSCServer();
  }

}

ConcurrentLinkedQueue<JSONObject> addChannel(int deviceID) {
  ConcurrentLinkedQueue<JSONObject> queue = new ConcurrentLinkedQueue<JSONObject>();
  queues.put(deviceID, queue);

  Channel channel = new Channel(queue, "ocean.jpg");
  channels.put(deviceID, channel);

  Thread channelThread = new Thread(channel);
  channelThread.start();
  
  return queue;
}

void removeChannel(int deviceID) {
  queues.remove(deviceID);
  channels.remove(deviceID);
}


void draw() {
  // Draw all channels background
  Enumeration<Channel> channel = channels.elements();
  while (channel.hasMoreElements()) {
    channel.nextElement().drawBackground();
  }

  // Draw all channels
  channel = channels.elements();
  while (channel.hasMoreElements()) {
    channel.nextElement().drawAll();
  }
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


