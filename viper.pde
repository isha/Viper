import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

// Channel list
Channel ch1;

// Instruction placeholder
JSONObject instr;

// Image list
Hashtable<Integer, PImage> images = new Hashtable<Integer, PImage>();
Integer imagesCount = 0;

void setup() {
  size(1000, 600);

  ch1.instructions = loadJSONArray("sampleInstructions1.json");
}

void draw() {
  if (frameCount % 8 == 0) {
    background(255, 204, 0);

    // Get instruction
    if (ch1.nextInstructionExists()) {
      instr = ch1.nextInstruction();
    }

    // Run instruction
    if (instr.getString("Method").equals("create")) {
      PImage img = loadImage(instr.getString("Image"));

      images.put(imagesCount, img);
      imagesCount++;

      image(img, instr.getInt("PositionX"), instr.getInt("PositionY"), img.width, img.height);
    }
    else if (instr.getString("Method").equals("update")) {
      PImage img = images.get(instr.getInt("Image"));

      if (instr.getString("Action").equals("position")) {
        image(img, instr.getInt("PositionX"), instr.getInt("PositionY"), img.width, img.height);
      }
    }
    else if (instr.getString("Method").equals("delete")) {

    }
  }
}
