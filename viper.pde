import java.util.Map;
import java.util.Iterator;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import processing.video.*;
import gifAnimation.*;
import g4p_controls.*;
import processing.opengl.*;
import java.util.Map.Entry;

static String VERSION = "1.0.1";

static boolean TESTMODE;
static boolean RECORD;
static boolean VERBOSE_LOG;

static int ASPECT_RATIO_W;
static int ASPECT_RATIO_H;
static int WIDTH;
static int HEIGHT;

static int GUI_WIDTH = 480;
static int GUI_HEIGHT = 420;


PApplet main_app;

LinkedHashMap<String, Channel> channels;
LinkedHashMap<String, ConcurrentLinkedQueue<JSONObject>> queues;
LinkedHashMap<String, PrintWriter> recorders;
ConcurrentLinkedQueue<JSONObject> mainQueue;

ServerManagement oscServer = new ServerManagement();
boolean performance_started = false;

void setup() {
  size(GUI_WIDTH, GUI_HEIGHT);
  main_app = this;

  createGUI();
  customGUI();

  channels = new LinkedHashMap<String, Channel>();
  queues = new LinkedHashMap<String, ConcurrentLinkedQueue<JSONObject>>();

  frame.setResizable(true);
}

void draw() {
  if (performance_started) {
    main_app.background(230);

    // Draw all channels
    for (Channel channel : channels.values()) {
      channel.drawAll(main_app);
    }
  }
}

// Called by Run button in GUI
void runViper() {
  populateGlobals();
  populateJSONFromFields();
  prepareStageWindow();

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

void prepareStageWindow() {
  removeGUI();
  HEIGHT = ((int) (WIDTH*((float) ASPECT_RATIO_H/ASPECT_RATIO_W)));
  frame.setSize(WIDTH, HEIGHT);
  performance_started = true;
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

