import oscP5.*;
import netP5.*;

class OSCServer {
  OscP5 viperServer;
  NetAddress hostLocation;
  
  String[] registeredDevices;
  int numDevices;
  int numPorts;
  int MAXDEVICES = 200;
  int MAXPORTS = 20;
  int DEFAULTPORT = 12000;

  OSCServer() {
    registeredDevices = new String[MAXDEVICES];

    loadServerConfig();
    loadRegisteredDevices();
    hostLocation = new NetAddress("127.0.0.1", 12002);
  }

  protected void loadServerConfig() {
    JSONObject serverConfig;
    int[] ports;
    int startPort, endPort;
    int i;
    
    ports = new int[MAXPORTS];
    try {
      // Try loading the server config file and retrieving the configuration
      serverConfig = loadJSONObject("serverConfig.json");
      startPort = serverConfig.getInt("StartPort");
      endPort = serverConfig.getInt("EndPort");
      
      numPorts = endPort-startPort+1;
      if(numPorts < 0 || numPorts > MAXPORTS) {
        Exception fileError = new Exception("Port configuration may be corrupted. Check serverConfig.txt file.");
        throw fileError;
      }
      
      for(i=startPort; i<=endPort; i++) {
        ports[i-startPort] = i;
      }
    } catch (Exception e) {
      print(e.getMessage());
      // If loading the config file fails, set to default values
      for(i=0;i<MAXPORTS;i++) {
        ports[i] = DEFAULTPORT + i;
      }
      startPort = DEFAULTPORT;
      endPort = DEFAULTPORT + MAXPORTS - 1;
      numPorts = MAXPORTS;
    }
    
    viperServer = new OscP5(this, ports[0]);
    for(i=1;i<numPorts;i++) {
      new OscP5(this, ports[i]);
    }
  }
  
  void loadRegisteredDevices() {
    BufferedReader reader;
    String line;
    int lineCount = 0;
    
    try {
      reader = createReader("registeredDevices.txt");
      do {
        line = reader.readLine();
        
        if(line==null) {
          break;
        }
        
        registeredDevices[lineCount] = line;
       
        lineCount++; 
      } while(line!=null);
    } catch (Exception e) {
      // File unreadable or corrupted
      e.printStackTrace();
    }
    numDevices = lineCount;
  }
  
  void sendTestMessage(OscMessage testMessage, NetAddress sendLoc) {
    viperServer.send(testMessage, sendLoc);
  }

  void testEasing(OscMessage message) {
    // creates a sample easing message
    message.add("deviceId");
    message.add("10295710feajawMwn11j");
    message.add("method");
    message.add("create");
    message.add("posX");
    message.add(35);
    message.add("posY");
    message.add(120);
    message.add("image");
    message.add("fish2.gif");
    
    message.add("method");
    message.add("update");
    message.add("easing");
    message.add(0.008);
    message.add("endX");
    message.add(1000);
    message.add("endY");
    message.add(500);
  }

  void mousePressed() {
    // create an osc message
    OscMessage testMessage = new OscMessage("/rime");

    testEasing(testMessage);

    sendTestMessage(testMessage, hostLocation);
  }

  /*
    Event
    Triggers when the server receives an OSC message
   */ 
  void oscEvent(OscMessage recvMsg) {
    JSONArray commandArray;
    JSONObject command;
    String recvMsgType;
    String messagePair;
    String argType;
    String deviceID;
    String saveLoc;
    int recvMsgLength;
    int commandCount;
    int i;

    if(recvMsg.checkAddrPattern("/rime") == false) {
      //if the OSC message is received without address tag '/rime',
      //consider it a rogue message and discard
      return;
    }
    
    if(recvMsg.get(0).stringValue().equals("deviceId")) {
      deviceID = recvMsg.get(1).stringValue();
    } else {
      //if the deviceID is not the first thing we find, 
      //consider it a rouge message and discard
      return;
    }
    
    commandArray = new JSONArray();

    recvMsgType = recvMsg.typetag();
    recvMsgLength = (recvMsgType.length()) / 2;

    commandCount = 0;
    command = new JSONObject();
    for(i=0; i<recvMsgLength; i++) {
      messagePair = recvMsgType.substring(i*2, i*2 + 2);
      if (recvMsg.get(i*2).stringValue().equals("method")) {
        if (commandCount!=0) {
          commandArray.setJSONObject(commandCount-1, command);
          command = new JSONObject();
        }
        commandCount++;
      }
      argType = messagePair.substring(1);
      if (argType.equals("i")) {
        command.setInt(recvMsg.get(i*2).stringValue(), recvMsg.get(i*2+1).intValue());
      } else if (argType.equals("f")) {
        command.setFloat(recvMsg.get(i*2).stringValue(), recvMsg.get(i*2+1).floatValue());
      } else if (argType.equals("s")) {
        command.setString(recvMsg.get(i*2).stringValue(), recvMsg.get(i*2+1).stringValue());
      }
    }
    commandArray.setJSONObject(commandCount-1, command);
    print(commandArray);
    if(deviceID != null) {
      saveLoc = "data/" + deviceID + ".json";
      saveJSONArray(commandArray, saveLoc);
    }
  }
  
  int getNumDevices() {
    return numDevices;
  }
  
  int getNumPorts() {
    return numPorts;
  }
  
  String[] getRegisteredDeviceIDs() {
    return registeredDevices;
  }
};
