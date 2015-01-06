import oscP5.*;
import netP5.*;

int DEFAULT_PORT = 11000;
int DEFAULT_NUM_PORTS = 1;
int NUM_PORTS = DEFAULT_NUM_PORTS;
int PORT = DEFAULT_PORT;

class OSCServer {
  OscP5 viperServer;
  NetAddress hostLocation;
  
  String[] registeredDevices;
  int numDevices;
  int numPorts;
  int MAXDEVICES = 200;
  int MAXPORTS = 100;

  OSCServer() {
    registeredDevices = new String[MAXDEVICES];

    loadServer();
    loadRegisteredDevices();
    hostLocation = new NetAddress("127.0.0.1", 11000);
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
  
  void sendMessage(OscMessage testMessage, NetAddress sendLoc) {
    viperServer.send(testMessage, sendLoc);
  }

  void sendDataList(String deviceID, String deviceAddr, Integer devicePort) {
    OscMessage dataList = new OscMessage("/viper");
    dataList.add(",");
    readDataFolder(dataList);
    
    NetAddress rimeLocation = new NetAddress(deviceAddr, devicePort);
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
      for(i=0;i<numDevices;i++) {
        if(registeredDevices[i].equals(deviceID)) {
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
    
    if(recvMsg.get(3).stringValue().equalsIgnoreCase("datalist")) {
      // Send the data list (complete list of all images' and videos' filenames if requested
      delay(5);
      sendDataList(deviceID, recvMsg.netAddress().address(), recvMsg.netAddress().port());
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
        dataList.add(filename + ",");
      }
    } else if(filename.length() > 4) {
      if(!(filename.substring(filename.length()-4, filename.length()).equalsIgnoreCase(".txt"))) {
        dataList.add(filename + ",");
      }
    } else {
      dataList.add(filename + ",");
    }
  }

};
