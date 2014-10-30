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
    if (instr.getString("method").equals("create")) {
      Image img = new Image(instr.getString("image"), instr.getInt("posX"), instr.getInt("posY"));

      images.put(imagesCount, img);
      imagesCount++;
    }
    else if (instr.getString("method").equals("update")) {
      Image img = images.get(instr.getInt("id"));

      if (instr.hasKey("easing")) {
        img.setEasing(instr.getFloat("easing"));
      }

      if (instr.hasKey("width") && instr.hasKey("height")) {
        img.updateSize(instr.getInt("width"), instr.getInt("height"));
      }

      img.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
    }
    else if (instr.getString("method").equals("delete")) {
      images.remove(instr.getInt("id"));
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
