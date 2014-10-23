class TestChannel extends Channel {
  JSONObject instr;
  JSONArray instructions;
  Integer instructionCounter = 0;

  PImage backImage;

  TestChannel(String sampleInstructionFile, String backImageFile) {
    backImage = loadImage(backImageFile);
    size(backImage.width, backImage.height);

    instructions = loadJSONArray(sampleInstructionFile);
  }

  void draw() {
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
        img.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
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
};

class Channel {
  Hashtable<Integer, Image> images;
  int imagesCount = 0;

  Channel() {
    images = new Hashtable<Integer, Image>();
  }

  void draw() {

  }
};
