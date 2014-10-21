import java.util.Map;
import java.util.Hashtable;
import java.io.*;
import java.util.*;

static final int FRAMERATE = 2;

// Sample instructions
JSONObject instr;
JSONArray instructions;
Integer instructionCounter = 0;

// Image list
Hashtable<Integer, Image> images = new Hashtable<Integer, Image>();
Integer imagesCount = 0;

// Background image
PImage backImage;

void setup() {
  backImage = loadImage("ocean.jpg");
  size(backImage.width, backImage.height);

  instructions = loadJSONArray("sampleComplexInstructions.json");
}

void draw() {
  if (frameCount % FRAMERATE == 0) {
    image(backImage, 0, 0);

    // Get instruction
    if (instructionCounter < instructions.size()) {
      instr = instructions.getJSONObject(instructionCounter++);
    }

    // Run instruction
    if (instr.getString("Method").equals("create")) {
      Image img = new Image(instr.getString("Image"), instr.getInt("PositionX"), instr.getInt("PositionY"));

      images.put(imagesCount, img);
      imagesCount++;
    }
    else if (instr.getString("Method").equals("update")) {
      Image img = images.get(instr.getInt("Image"));

      if (instr.getString("Action").equals("position")) {
        img.updatePostion(instr.getInt("PositionX"), instr.getInt("PositionY"));
      }
      else if (instr.getString("Action").equals("resize")) {
        img.updateSize(instr.getInt("Width"), instr.getInt("Height"));
      }
    }
    else if (instr.getString("Method").equals("delete")) {
      images.remove(instr.getInt("Image"));
    }

    // Draw all images
    for (int i=0; i<images.size(); i++) {
      images.get(i).draw();
    }
  }
}

class Image {
  int x, y;
  PImage picture;

  Image(String filename, int posX, int posY) {
    picture = loadImage(filename);
    x = posX;
    y = posY;
  }

  void updatePostion(int posX, int posY) {
    x = posX;
    y = posY;
  }

  void updateSize(int w, int h) {
    picture.resize(w, h);
  }

  void draw() {
    image(picture, x, y);
  }
};
