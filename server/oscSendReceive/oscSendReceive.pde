import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400, 400);
  
  // start oscP5, telling it to listen for incoming messages at port 5001
  oscP5 = new OscP5(this, 5001);
  
  // set the remote location to be the localhost on port 5001
  myRemoteLocation = new NetAddress("127.0.0.1", 5001); 
}

void draw() {
  ;
}

void mousePressed() {
  // create an osc message
  OscMessage myMessage = new OscMessage("/rime");
  
  myMessage.add("command");
  myMessage.add(123); // add an int to the osc message
  myMessage.add("posX");
  myMessage.add(12.34); // add a float to the osc message
  myMessage.add("posY");
  myMessage.add("some text!"); // add a string to the osc message
  myMessage.add("posZ");
  myMessage.add(5123);
  
  myMessage.add("command");
  myMessage.add("coajs"); // add an int to the osc message
  myMessage.add("arg1");
  myMessage.add(13.1624); // add a float to the osc message
  myMessage.add("arg2");
  myMessage.add("textxxxxxxx!"); // add a string to the osc message
  myMessage.add("arg3");
  myMessage.add(135910275);
  
  
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
     if(theOscMessage.get(i*2).stringValue().equals("command")) {
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
  
//  print(" addrpattern: "+theOscMessage.addrPattern());
  //print(" typetag: "+theOscMessage.typetag());*/  
}
