import java.util.Map;
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

HashMap<String, Channel> channels;
HashMap<String, ConcurrentLinkedQueue<JSONObject>> queues;
HashMap<String, PrintWriter> recorders;
ConcurrentLinkedQueue<JSONObject> mainQueue;

OSCServer oscServer = new OSCServer();

void setup() {
  size(480, 320);
  if (frame != null) {
    frame.setResizable(true);
  }
  main_app = this;

  createGUI();
  String myWAN = NetInfo.wan();
  ip.setText(myWAN);

  channels = new HashMap<String, Channel>();
  queues = new HashMap<String, ConcurrentLinkedQueue<JSONObject>>();
}

void draw() {}

// Called by Run button in GUI
void runViper() {
  createStageWindow();

  if (RECORD) {
    recorders = new HashMap<String, PrintWriter>();
    
    PrintWriter recorder = createWriter("logs/master/messages.json");
    recorders.put("master", recorder);
  }

  mainQueue = new ConcurrentLinkedQueue<JSONObject>();

  if (TESTMODE) {
    addTestChannels();
  } else {
    oscServer.runServer();
  }

  Thread delegateInstructions = new Thread(new InstructionDelegator(mainQueue));
  delegateInstructions.start();
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
  recorders.remove(deviceID);
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

  p_window = new GWindow(this, "Performance Window", 0, 0, sketchWidth, sketchHeight, false, OPENGL);
  p_window.setActionOnClose(G4P.CLOSE_WINDOW);
  p_window.addDrawHandler(this, "p_window_draw1");
}

synchronized public void p_window_draw1(GWinApplet appc, GWinData data) {
  appc.background(230);

  // Draw all channels
  for (Channel channel : channels.values()) {
    channel.drawAll(appc);
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

