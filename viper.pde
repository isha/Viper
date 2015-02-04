import java.util.Map;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;
import g4p_controls.*;
import processing.opengl.*;

static String VERSION = "1.0.1";

static boolean TESTMODE;
static boolean RECORD;
static boolean VERBOSE_LOG;

static int ASPECT_RATIO_W;
static int ASPECT_RATIO_H;
static int WIDTH;
static int HEIGHT;

PApplet main_app;
GWindow p_window;

LinkedHashMap<String, Channel> channels;
LinkedHashMap<String, ConcurrentLinkedQueue<JSONObject>> queues;
LinkedHashMap<String, PrintWriter> recorders;
ConcurrentLinkedQueue<JSONObject> mainQueue;

ServerManagement oscServer = new ServerManagement();

void setup() {
  size(480, 420);
  main_app = this;

  createGUI();
  version_label.setText("Version: "+VERSION);

  if (!TESTMODE) {
    String myWAN = NetInfo.wan();
    ip.setText(myWAN);
  }

  channels = new LinkedHashMap<String, Channel>();
  queues = new LinkedHashMap<String, ConcurrentLinkedQueue<JSONObject>>();
}

void draw() {}

// Called by Run button in GUI
void runViper() {
  createStageWindow();

  if (RECORD) {
    recorders = new LinkedHashMap<String, PrintWriter>();
    
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
  sketchWidth = WIDTH; 
  sketchHeight = ((int) (WIDTH*((float) ASPECT_RATIO_H/ASPECT_RATIO_W))); 
  HEIGHT = sketchHeight;

  p_window = new GWindow(this, "Performance Window", 0, 0, sketchWidth, sketchHeight, false, OPENGL);
  p_window.setActionOnClose(G4P.CLOSE_WINDOW);
  // p_window.addOnCloseHandler(this, "p_window_close1");
  p_window.addDrawHandler(this, "p_window_draw1");
}

public void p_window_close1(GWindow source) {
  oscServer.closeServer();
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

