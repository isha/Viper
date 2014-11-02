import oscP5.*;
import netP5.*;

class OSCServer {
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  NetAddress hostLocation;

  OSCServer() {
    loadConfig();
    myRemoteLocation = new NetAddress("127.0.0.1", 5003);
    hostLocation = new NetAddress("127.0.0.1", 5003);
  }

  protected void loadConfig() {
    JSONObject serverConfig;
    int port;
    try {
      // Try loading the server config file and retrieving the configuration
      serverConfig = loadJSONObject("serverConfig.json");
      port = serverConfig.getInt("port");
    } 
    catch (Exception e) {
      // If loading the config file fails, set to default values
      port = 5001;
    }

    oscP5 = new OscP5(this, port);
  }

  void sendTestMessage(OscMessage testMessage, NetAddress sendLoc) {
    oscP5.send(testMessage, sendLoc);
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
    OscMessage myMessage = new OscMessage("/rime");

    testEasing(myMessage);

    sendTestMessage(myMessage, hostLocation);
  }

  void oscEvent(OscMessage theOscMessage) {
    JSONArray commands;
    JSONObject command;
    String recvMessageType;
    String messagePair;
    String argType;
    int recvMessageLength;
    int commandCount;
    int i;

    if ( theOscMessage.checkAddrPattern("/rime") == false ) {
      return;
    }

    commands = new JSONArray();

    recvMessageType = theOscMessage.typetag();
    recvMessageLength = (recvMessageType.length()) / 2;

    commandCount = 0;
    command = new JSONObject();
    for (i=0; i<recvMessageLength; i++) {
      messagePair = recvMessageType.substring(i*2, i*2 + 2);
      if (theOscMessage.get(i*2).stringValue().equals("deviceId")) {
        if (commandCount!=0) {
          commands.setJSONObject(commandCount-1, command);
          command = new JSONObject();
        }
        commandCount++;
      }
      argType = messagePair.substring(1);
      if (argType.equals("i")) {
        command.setInt(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).intValue());
      } else if (argType.equals("f")) {
        command.setFloat(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).floatValue());
      } else if (argType.equals("s")) {
        command.setString(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).stringValue());
      }
    }
    commands.setJSONObject(commandCount-1, command);
    print(commands);
    saveJSONArray(commands, "data/commands.json");
  }
};

