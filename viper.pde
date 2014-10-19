import java.util.Map;
import java.util.Hashtable;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.*;
import java.util.*;

// Sample instructions
JSONObject instr;
JSONArray instructions;
Integer instructionCounter = 0;

// Image list
Hashtable<Integer, PImage> images = new Hashtable<Integer, PImage>();
Integer imagesCount = 0;

BufferedReader reader;

void setup() {
  size(1000, 600);

  instructions = loadJSONArray("sampleResizingInstructions.json");
}

void draw() {
  if (frameCount % 8 == 0) {
    background(255, 204, 0);

    // Get instruction
    if (instructionCounter < instructions.size()) {
      instr = instructions.getJSONObject(instructionCounter++);
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
      else if (instr.getString("Action").equals("resize")) {
        img.resize(instr.getInt("Width"), instr.getInt("Height"));
        image(img, instr.getInt("PositionX"), instr.getInt("PositionY"), img.width, img.height);
      }
    }
    else if (instr.getString("Method").equals("delete")) {

    }
  }
}
