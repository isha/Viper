import oscP5.*;
import netP5.*;

class OSCServer {
  OscP5 viperServer;
  NetAddress hostLocation;

  OSCServer() {
    loadServerConfig();
    hostLocation = new NetAddress("127.0.0.1", 5003);
  }

  protected void loadServerConfig() {
    JSONObject serverConfig;
    int port;
    try {
      // Try loading the server config file and retrieving the configuration
      serverConfig = loadJSONObject("serverConfig.json");
      port = serverConfig.getInt("port");
    } catch (Exception e) {
      // If loading the config file fails, set to default values
      port = 5001;
    }

    viperServer = new OscP5(this, port);
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

    message.add("deviceId");
    message.add("10295710feajawMwn11j");
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
    int recvMsgLength;
    int commandCount;
    int i;

    if(recvMsg.checkAddrPattern("/rime") == false) {
      //if the OSC message is received without address tag '/rime',
      //consider it a rogue message and discard
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
    saveJSONArray(commandArray, "data/commands.json");
  }
};

