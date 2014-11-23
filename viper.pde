import java.util.Map;
import java.util.Hashtable;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;
import g4p_controls.*;


static boolean TESTMODE = false;
static boolean RECORD = false;
static int WIDTH = 1000;
static int HEIGHT = 600;

PApplet main_app;

Hashtable<String, Channel> channels;
Hashtable<String, ConcurrentLinkedQueue<JSONObject>> queues;
Hashtable<String, PrintWriter> recorders;
ConcurrentLinkedQueue<JSONObject> mainQueue;

OSCServer oscServer;
GWindow p_window;

void setup() {
  size(480, 320);
  
  main_app = this;
  channels = new Hashtable<String, Channel>();
  queues = new Hashtable<String, ConcurrentLinkedQueue<JSONObject>>();
  createGUI();
}

synchronized public void p_window_draw1(GWinApplet appc, GWinData data) { //_CODE_:p_window:303508:
  appc.background(230);

  // Draw all channels background
  Enumeration<Channel> channel = channels.elements();
  while (channel.hasMoreElements ()) {
    channel.nextElement().drawBackground(appc);
  }

  // Draw all channels
  channel = channels.elements();
  while (channel.hasMoreElements ()) {
    channel.nextElement().drawAll(appc);
  }

} //_CODE_:p_window:303508:


void runViper() {
  p_window = new GWindow(this, "Performance Window", 0, 0, WIDTH, HEIGHT, false, JAVA2D);
  p_window.setActionOnClose(G4P.CLOSE_WINDOW);
  p_window.addDrawHandler(this, "p_window_draw1");

  if (RECORD) {
    recorders = new Hashtable<String, PrintWriter>();
    
    PrintWriter recorder = createWriter("logs/master/messages.json");
    recorders.put("master", recorder);
  }

  if (TESTMODE) {
    ConcurrentLinkedQueue<JSONObject> queue1 = addChannel("1");
    // ConcurrentLinkedQueue<JSONObject> queue2 = addChannel("2");
    // ConcurrentLinkedQueue<JSONObject> queue3 = addChannel("3");
    mainQueue = new ConcurrentLinkedQueue<JSONObject>();

    Thread instructionReader1 = new Thread(new InstructionReader(mainQueue, "sampleRotateInstructions.json"));
    instructionReader1.start();

    // Thread instructionReader2 = new Thread(new InstructionReader(mainQueue, "demo/instructions2.json"));
    // instructionReader2.start();

    // Thread instructionReader3 = new Thread(new InstructionReader(mainQueue, "demo/instructions3.json"));
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

  Channel channel = new Channel(queue);
  channels.put(deviceID, channel);

  Thread channelThread = new Thread(channel);
  channelThread.start();

  if (RECORD) {
    String first = "logs/";
    String last = "/messages.json";
    String filename = first + deviceID + last;

    PrintWriter recorder = createWriter(filename);
    recorders.put(deviceID, recorder);
  }

  return queue;
}

void removeChannel(String deviceID) {
  queues.remove(deviceID);
  channels.remove(deviceID);
}


void draw() {
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
