import oscP5.*;
import netP5.*;

int DEFAULT_PORT = 11000;
int DEFAULT_NUM_PORTS = 1;
int NUM_PORTS = DEFAULT_NUM_PORTS;
int PORT = DEFAULT_PORT;

class ServerManagement{
  OSCServer[] viperServers;
  
  String[] registeredDevices;
  int numDevices;
  int numPorts = 0;
  int MAXDEVICES = 200;
  int MAXPORTS = 100;
  
  ServerManagement() {
    registeredDevices = new String[MAXDEVICES];
  }
  
  public void runServer() {
    loadServer();
    loadRegisteredDevices();
  }
  
  
  public void closeServer() {
    for(int i=0;i<numPorts;i++) {
      viperServers[i].stopServer();
    }
  }
  
  protected void loadServer() {
    int[] ports;
    int startPort;
    int i;
    
    try {
      // Try loading the server config file and retrieving the configuration
      numPorts = NUM_PORTS;
      startPort = PORT;
      
      if(numPorts < 0 || numPorts > MAXPORTS) {
        Exception fileError = new Exception("Port configuration may be corrupted. Check serverConfig.txt file.");
        throw fileError;
      }
    } catch (Exception e) {
      print(e.getMessage());
      // If loading the config file fails, set to default values
      numPorts = DEFAULT_NUM_PORTS;
      startPort = DEFAULT_PORT;      
    }
    
    ports = new int[numPorts];
    for(i=0; i<numPorts; i++) {
      ports[i] = startPort + i;
    }
    
    viperServers = new OSCServer[numPorts];
   
    for(i=0;i<numPorts;i++) {
      viperServers[i] = new OSCServer(ports[i], this);
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
  
  public boolean checkID(String deviceID) {
    for(int i=0;i<numDevices;i++) {
      if(registeredDevices[i].equals(deviceID)) {
         return true;
      }
    }
    return false;
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

class OSCServer {
  OscP5 server;
  ServerManagement _serverMng;
  
  
  OSCServer(int port, ServerManagement serverMng) {
    OscProperties _serverProperties = new OscProperties();
    _serverProperties.setSRSP(true);
    _serverProperties.setListeningPort(port);
    _serverProperties.setEventMethod("onMessageReceive");
    server = new OscP5(this, _serverProperties);
    
    _serverMng = serverMng;
  }
  
  void stopServer() {
    server.stop();
  }
  
  void sendMessage(OscMessage testMessage, String deviceAddr, Integer devicePort) {
    NetAddress sendLoc = new NetAddress(deviceAddr, devicePort);
    server.send(testMessage, sendLoc);
  }
  
  void sendDataList(String deviceID, String deviceAddr, Integer devicePort) {
    OscMessage dataList = new OscMessage("/viper");
    readDataFolder(dataList);
    
    sendMessage(dataList, deviceAddr, devicePort);
  }
 
  void sendConnectAck(String deviceAddr, Integer devicePort) {
    OscMessage connectAck = new OscMessage("/viper");
    connectAck.add("ack");
    
    sendMessage(connectAck, deviceAddr, devicePort);
  }

  /*
    Event
    Triggers when the server receives an OSC message
   */ 
  void onMessageReceive(OscMessage recvMsg) {
    JSONObject command;
    String recvMsgType;
    String messagePair;
    String argType;
    String deviceID;
    int recvMsgLength;
    int commandCount;
    int i;
    boolean goodID = false;
    
    if(VERBOSE_LOG == true) {
      // print incoming OSC messages if verbose log is on
      recvMsg.print(); 
    }
    
    if(recvMsg.checkAddrPattern("/rime") == false) {
      //if the OSC message is received without address tag '/rime',
      //consider it a rogue message and discard
      return;
    }
    
    if(recvMsg.typetag().length() < 4) {
      return;
    }
    
    if(recvMsg.get(0).stringValue().equalsIgnoreCase("deviceId")) {
      deviceID = recvMsg.get(1).stringValue();
      if(_serverMng.checkID(deviceID)) {
        goodID = true;
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
    
    if(recvMsg.get(3).stringValue().equalsIgnoreCase("datalist")) {
      // Send the data list (complete list of all images' and videos' filenames if requested
      delay(5);
      sendDataList(deviceID, recvMsg.netAddress().address(), recvMsg.netAddress().port());
      return;
    } else if(recvMsg.get(3).stringValue().equalsIgnoreCase("connect")) {
      // Send acknowledge message when connecting
      delay(5);
      sendConnectAck(recvMsg.netAddress().address(), recvMsg.netAddress().port());
      return;
    }
    
    // if this is the first time a device is sending a command,
    // allocate a channel for this device
    if(!channels.containsKey(deviceID)) {
      addChannel(deviceID);
    }
    
    recvMsgType = recvMsg.typetag();
    recvMsgLength = (recvMsgType.length()) / 2;

    commandCount = 0;
    command = new JSONObject();
    for(i=0; i<recvMsgLength; i++) {
      messagePair = recvMsgType.substring(i*2, i*2 + 2);
      if(recvMsg.get(i*2).stringValue().equalsIgnoreCase("deviceId")) {
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
    if(RECORD)
    {
      command.setInt("time", millis());
    }
    mainQueue.add(command);
  }
  
  void readDataFolder(OscMessage dataList) {
    // we'll have a look in the data folder
    File folder = new File(dataPath(""));
     
    getFilenames(dataList, folder, "");    
  }

  void getFilenames(OscMessage dataList, File folder, String prefix) {
    // list the files in the data folder
    //String[] filenames = folder.list();
    File[] filenames = folder.listFiles();
    String newPrefix;
    
    // display the filenames
    for (int i=0; i<filenames.length; i++) {
      if(filenames[i].isDirectory()) {
        if(prefix == "") {
          newPrefix = filenames[i].getName();
        } else {
          newPrefix = prefix + "/" + filenames[i].getName();
        }
        getFilenames(dataList, filenames[i], newPrefix);
      } else if(filenames[i].isFile()) {
        if(prefix == "") {
          filterFilenames(dataList, filenames[i].getName());
        } else {
          filterFilenames(dataList, prefix + "/" + filenames[i].getName());
        }
      }
    }
  }
  
  void filterFilenames(OscMessage dataList, String filename) {
    if(filename.length() > 5) {
      if(!(filename.substring(filename.length()-5, filename.length()).equalsIgnoreCase(".json")) &&
          !(filename.substring(filename.length()-4, filename.length()).equalsIgnoreCase(".txt"))) {
        dataList.add(filename);
      }
    } else if(filename.length() > 4) {
      if(!(filename.substring(filename.length()-4, filename.length()).equalsIgnoreCase(".txt"))) {
        dataList.add(filename);
      }
    } else {
      dataList.add(filename);
    }
  }

};
