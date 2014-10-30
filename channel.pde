class Channel {
  Hashtable<Integer, Image> images;
  PImage backImage;

  ConcurrentLinkedQueue<JSONObject> queue;
  
  Channel(ConcurrentLinkedQueue<JSONObject> queue, String backImageFile) {
    images = new Hashtable<Integer, Image>();

    backImage = loadImage(backImageFile);
    size(backImage.width, backImage.height);

    this.queue = queue;
  }

  void draw() {
    image(backImage, 0, 0);

    // Get instruction
    JSONObject instr;
    instr = queue.poll();

    if (instr != null) {
      // Run instruction
      if (instr.getString("method").equals("create")) {
        Image img = new Image(instr.getString("image"), instr.getInt("posX"), instr.getInt("posY"));
        images.put(instr.getInt("id"), img);
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
    }

    // Draw all images
    for (int i=0; i<images.size(); i++) {
      images.get(i).draw();
    }
  }
};
