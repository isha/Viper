import oscP5.*;
import netP5.*;

class OSCServer {
  OscP5 viperServer;
  NetAddress hostLocation;
  
  String[] registeredDevices;
  String[] registeredDeviceAddresses;
  Integer[] registeredDevicePorts;
  int numDevices;
  int numPorts;
  int MAXDEVICES = 200;
  int MAXPORTS = 100;
  int DEFAULTPORT = 12000;
  int DEFAULTNUMPORTS = 20;

  OSCServer() {
    registeredDevices = new String[MAXDEVICES];
    registeredDeviceAddresses = new String[MAXDEVICES];
    registeredDevicePorts= new Integer[MAXDEVICES];

    loadServerConfig();
    loadRegisteredDevices();
    hostLocation = new NetAddress("127.0.0.1", 12000);
  }

  protected void loadServerConfig() {
    JSONObject serverConfig;
    int[] ports;
    int startPort;
    int i;
    
    try {
      // Try loading the server config file and retrieving the configuration
      serverConfig = loadJSONObject("serverConfig.json");
      numPorts = serverConfig.getInt("NumberOfPorts");
      startPort = serverConfig.getInt("StartPort");
      
      if(numPorts < 0 || numPorts > MAXPORTS) {
        Exception fileError = new Exception("Port configuration may be corrupted. Check serverConfig.txt file.");
        throw fileError;
      }
    } catch (Exception e) {
      print(e.getMessage());
      // If loading the config file fails, set to default values
      numPorts = DEFAULTNUMPORTS;
      startPort = DEFAULTPORT;      
    }
    
    ports = new int[numPorts];
    for(i=0; i<numPorts; i++) {
      ports[i] = startPort + i;
    }
    
    viperServer = new OscP5(this, ports[0]);
    for(i=1;i<numPorts;i++) {
      new OscP5(this, ports[i]);
    }
  }
  
  void loadRegisteredDevices() {
    BufferedReader reader;
    String line;
    String[] lineTokens;
    int lineCount = 0;
    
    try {
      reader = createReader("registeredDevices.txt");
      do {
        line = reader.readLine();
        
        if(line==null) {
          break;
        } else {
          lineTokens = splitTokens(line, ", ");
        }
        
        registeredDevices[lineCount] = lineTokens[0];
        registeredDeviceAddresses[lineCount] = lineTokens[1];
        registeredDevicePorts[lineCount] = int(lineTokens[2]);
        lineCount++; 
      } while(line!=null);
    } catch (Exception e) {
      // File unreadable or corrupted
      e.printStackTrace();
    }
    numDevices = lineCount;
  }
  
  void sendMessage(OscMessage testMessage, NetAddress sendLoc) {
    viperServer.send(testMessage, sendLoc);
  }

  void testEasing(OscMessage message) {
    // creates a sample easing message
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
    
    message.add("method");
    message.add("create");
    message.add("posX");
    message.add(35);
    message.add("posY");
    message.add(120);
    message.add("image");
    message.add("fish1.gif");
    message.add("id");
    message.add(7);
    
    message.add("method");
    message.add("create");
    message.add("posX");
    message.add(800);
    message.add("posY");
    message.add(320);
    message.add("image");
    message.add("shark.gif");
    message.add("id");
    message.add(11);
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
    
    message.add("method");
    message.add("create");
    message.add("posX");
    message.add(1200);
    message.add("posY");
    message.add(60);
    message.add("image");
    message.add("magical-starfish.gif");
    message.add("id");
    message.add(2);
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
    
    message.add("method");
    message.add("update");
    message.add("id");
    message.add(2);
    message.add("blur");
    message.add(6);
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
    
    message.add("method");
    message.add("update");
    message.add("id");
    message.add(11);
    message.add("easing");
    message.add(0.01);
    message.add("endX");
    message.add(20);
    message.add("endY");
    message.add(280);
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
    
    message.add("method");
    message.add("update");
    message.add("id");
    message.add(2);
    message.add("easing");
    message.add(0.005);
    message.add("endX");
    message.add(20);
    message.add("endY");
    message.add(100);
    message.add("deviceId");
    message.add("oijgoaij2ojgawojfiawfjoa");
  }

  void mousePressed() {
    // create an osc message    
    OscMessage testEasing = new OscMessage("/rime");
    testEasing(testEasing);
    sendMessage(testEasing, hostLocation);
  }

  void sendDataList(String deviceID, Integer deviceIndex) {
    OscMessage dataList = new OscMessage("/viper");
    readDataFolder(dataList);
    
    NetAddress rimeLocation = new NetAddress(registeredDeviceAddresses[deviceIndex], registeredDevicePorts[deviceIndex]);
    sendMessage(dataList, rimeLocation);
  }

  /*
    Event
    Triggers when the server receives an OSC message
   */ 
  void oscEvent(OscMessage recvMsg) {
    JSONObject command;
    String recvMsgType;
    String messagePair;
    String argType;
    String deviceID;
    int recvMsgLength;
    int commandCount;
    int deviceIndex;
    int i;
    boolean goodID = false;

    if(recvMsg.checkAddrPattern("/rime") == false) {
      //if the OSC message is received without address tag '/rime',
      //consider it a rogue message and discard
      return;
    }
    
    if(recvMsg.get(0).stringValue().equalsIgnoreCase("deviceId")) {
      deviceID = recvMsg.get(1).stringValue();
      for(deviceIndex=0;deviceIndex<numDevices;deviceIndex++) {
        if(registeredDevices[deviceIndex].equals(deviceID)) {
          goodID = true;
          break;
        }
      }
      if(goodID==false) {
        //if the device ID we got from message does not match any of the registered devices' ID
        //consider it a rogue message and discard
        return;
      }
    } else {
      //if the deviceID is not the first thing we find, 
      //consider it a rogue message and discard
      return;
    }
    
    if(recvMsg.get(2).stringValue().equalsIgnoreCase("datalist")) {
      // Send the data list (complete list of all images' and videos' filenames if requested
      sendDataList(deviceID, deviceIndex);
      return;
    }
    
    recvMsgType = recvMsg.typetag();
    recvMsgLength = (recvMsgType.length()) / 2;

    commandCount = 0;
    command = new JSONObject();
    for(i=0; i<recvMsgLength; i++) {
      messagePair = recvMsgType.substring(i*2, i*2 + 2);
      if(recvMsg.get(i*2).stringValue().equalsIgnoreCase("method")) {
        if (commandCount!=0) {
          mainQueue.add(command);
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
    mainQueue.add(command);
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
  
  void readDataFolder(OscMessage dataList) {
    // we'll have a look in the data folder
    File folder = new File(dataPath(""));
     
    // list the files in the data folder
    String[] filenames = folder.list();
    
    // display the filenames
    for (int i=0; i<filenames.length; i++) {
      if(filenames[i].length() > 5) {
        if(!(filenames[i].substring(filenames[i].length()-5, filenames[i].length()).equalsIgnoreCase(".json")) &&
            !(filenames[i].substring(filenames[i].length()-4, filenames[i].length()).equalsIgnoreCase(".txt"))) {
          dataList.add(filenames[i]);
        }
      } else if(filenames[i].length() > 4) {
        if(!(filenames[i].substring(filenames[i].length()-4, filenames[i].length()).equalsIgnoreCase(".txt"))) {
          dataList.add(filenames[i]);
        }
      } else {
        dataList.add(filenames[i]);
      }
    }
  }
};
