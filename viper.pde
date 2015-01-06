import java.util.Map;
import java.util.Hashtable;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;
import g4p_controls.*;
import processing.opengl.*;


static boolean TESTMODE = false;
static boolean RECORD = false;
static boolean VERBOSE_LOG = false;
static int DEFAULT_WIDTH = 1000;
static int DEFAULT_HEIGHT = 600;
static int WIDTH = DEFAULT_WIDTH;
static int HEIGHT = DEFAULT_HEIGHT;
static boolean FULLSCREEN = false;

PApplet main_app;
GWindow p_window;

Hashtable<String, Channel> channels;
Hashtable<String, ConcurrentLinkedQueue<JSONObject>> queues;
Hashtable<String, PrintWriter> recorders;
ConcurrentLinkedQueue<JSONObject> mainQueue;

OSCServer oscServer;

void setup() {
  size(480, 320);
  if (frame != null) {
    frame.setResizable(true);
  }
  main_app = this;

  createGUI();
  String myWAN = NetInfo.wan();
  ip.setText(myWAN);

  channels = new Hashtable<String, Channel>();
  queues = new Hashtable<String, ConcurrentLinkedQueue<JSONObject>>();
}

void draw() {}

void runViper() {
  createStageWindow();

  if (RECORD) {
    recorders = new Hashtable<String, PrintWriter>();
    
    PrintWriter recorder = createWriter("logs/master/messages.json");
    recorders.put("master", recorder);
  }

  if (TESTMODE) {
    mainQueue = new ConcurrentLinkedQueue<JSONObject>();
    addTestChannels();

    Thread delegateInstructions = new Thread(new InstructionDelegator(mainQueue));
    delegateInstructions.start();

  } else {

    oscServer = new OSCServer();

    mainQueue = new ConcurrentLinkedQueue<JSONObject>();
    
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

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void createStageWindow() {
  int sketchWidth, sketchHeight;
  if (FULLSCREEN) {
    sketchHeight = displayHeight; sketchWidth = displayWidth;
  } else {
    sketchHeight = HEIGHT; sketchWidth = WIDTH;
  }

  p_window = new GWindow(this, "Performance Window", 0, 0, sketchWidth, sketchHeight, true, OPENGL);
  p_window.setActionOnClose(G4P.CLOSE_WINDOW);
  p_window.addDrawHandler(this, "p_window_draw1");
}

synchronized public void p_window_draw1(GWinApplet appc, GWinData data) {
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

}

void addTestChannels() {
  String[] testFiles = new String[3];
  testFiles[0] = test_file_1.getText().trim();
  testFiles[1] = test_file_2.getText().trim();
  testFiles[2] = test_file_3.getText().trim();

  for (int i=0; i<3; i++) {
    if (!testFiles[i].isEmpty()) {
      InstructionReader ir = new InstructionReader(mainQueue, testFiles[i]);
      addChannel(ir.getDeviceId());

      Thread irThread = new Thread(ir);
      irThread.start();
    }
  }
}

