import java.util.Map;
import java.util.Hashtable;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;


static final boolean TESTMODE = false;

PApplet app;

Hashtable<String, Channel> channels;
Hashtable<String, ConcurrentLinkedQueue<JSONObject>> queues;
ConcurrentLinkedQueue<JSONObject> mainQueue;

OSCServer oscServer;

void setup() {
  app = this;
  channels = new Hashtable<String, Channel>();
  queues = new Hashtable<String, ConcurrentLinkedQueue<JSONObject>>();

  if (TESTMODE) {
    ConcurrentLinkedQueue<JSONObject> queue1 = addChannel("90");
    ConcurrentLinkedQueue<JSONObject> queue2 = addChannel("21");
    mainQueue = new ConcurrentLinkedQueue<JSONObject>();

    Thread instructionReader1 = new Thread(new InstructionReader(mainQueue, "sampleHueInstructions.json"));
    instructionReader1.start();
    Thread instructionReader2 = new Thread(new InstructionReader(mainQueue, "sampleTransparencyInstructions.json"));
    instructionReader2.start();
    // Thread instructionReader3 = new Thread(new InstructionReader(mainQueue, "sampleMasterInstructions.json"));
    // instructionReader3.start();

    Thread delegateInstructions = new Thread(new InstructionDelegator(mainQueue));
    delegateInstructions.start();
  } else {
    oscServer = new OSCServer();
    mainQueue = new ConcurrentLinkedQueue<JSONObject>();
    
    for (int i=0; i<oscServer.getNumDevices(); i++) {
      addChannel(oscServer.getRegisteredDeviceIDs()[i]);
    }
    Thread delegateInstructions = new Thread(new InstructionDelegator(mainQueue));
    delegateInstructions.start();
  }
}

ConcurrentLinkedQueue<JSONObject> addChannel(String deviceID) {
  ConcurrentLinkedQueue<JSONObject> queue = new ConcurrentLinkedQueue<JSONObject>();
  queues.put(deviceID, queue);

  Channel channel = new Channel(queue, "ocean.jpg");
  channels.put(deviceID, channel);

  Thread channelThread = new Thread(channel);
  channelThread.start();

  return queue;
}

void removeChannel(String deviceID) {
  queues.remove(deviceID);
  channels.remove(deviceID);
}


void draw() {
  // Draw all channels background
  Enumeration<Channel> channel = channels.elements();
  while (channel.hasMoreElements ()) {
    channel.nextElement().drawBackground();
  }

  // Draw all channels
  channel = channels.elements();
  while (channel.hasMoreElements ()) {
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
