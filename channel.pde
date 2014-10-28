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
          img.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
        }

        if (instr.hasKey("blur")) {
          img.blur(instr.getInt("blur"));
        }

        if (instr.hasKey("gray")) {
          img.gray();
        }

        if (instr.hasKey("invert")) {
          img.invert();
        }

        if (instr.hasKey("posterize")) {
          img.posterize(instr.getInt("posterize"));
        }

        if (instr.hasKey("erode")) {
          img.erode();
        }

        if (instr.hasKey("dilate")) {
          img.dilate();
        }

        if (instr.hasKey("threshold")) {
          img.threshold(instr.getFloat("threshold"));
        }
      }
      
      else if (instr.getString("method").equals("delete")) {
        images.remove(instr.getInt("id"));
      }
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
