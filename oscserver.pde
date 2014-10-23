import oscP5.*;
import netP5.*;

class OSCServer {
  OscP5 oscP5;
  NetAddress myRemoteLocation;

  OSCServer() {
    oscP5 = new OscP5(this, 5001);
    myRemoteLocation = new NetAddress("127.0.0.1", 5001);
  }
  
  void testEasing(OscMessage message) {
    // creates a sample easing message
    message.add("method");
    message.add("create");
    message.add("posX");
    message.add(35);
    message.add("posY");
    message.add(120);
    message.add("image");
    message.add("fish2.gif");

    message.add("id");
    message.add(0);
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

    // send the message
    oscP5.send(myMessage, myRemoteLocation);
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

    if( theOscMessage.checkAddrPattern("/rime") == false ) {
      return;
    }

    commands = new JSONArray();

    recvMessageType = theOscMessage.typetag();
    recvMessageLength = (recvMessageType.length()) / 2;

    commandCount = 0;
    command = new JSONObject();
    for(i=0;i<recvMessageLength;i++) {
       messagePair = recvMessageType.substring(i*2, i*2 + 2);
       if(theOscMessage.get(i*2).stringValue().equals("method")) {
         if(commandCount!=0) {
           commands.setJSONObject(commandCount-1, command);
           command = new JSONObject();
         }
         commandCount++;
       }
       argType = messagePair.substring(1);
       if(argType.equals("i")) {
         command.setInt(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).intValue());
       } else if(argType.equals("f")) {
         command.setFloat(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).floatValue());
       } else if(argType.equals("s")) {
         command.setString(theOscMessage.get(i*2).stringValue(), theOscMessage.get(i*2+1).stringValue());
       }
    }
    commands.setJSONObject(commandCount-1, command);
    saveJSONArray(commands, "data/commands.json");
  }
};
