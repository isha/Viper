class Channel implements Runnable {
  Hashtable<Integer, Image> images;
  Hashtable<Integer, Video> videos;
  PImage backImage;

  long currentTime;

  ConcurrentLinkedQueue<JSONObject> queue;
  
  Channel(ConcurrentLinkedQueue<JSONObject> queue, String backImageFile) {
    images = new Hashtable<Integer, Image>();
    videos = new Hashtable<Integer, Video>();

    backImage = loadImage(backImageFile);
    size(backImage.width, backImage.height);

    this.queue = queue;
  }

  void run() {
    while (true) {
      JSONObject instr;
      instr = queue.poll();

      // Run instruction if pending in queue

      if (instr != null) {
        if (instr.hasKey("master")) {
          Enumeration<Integer> v = videos.keys();
          while (v.hasMoreElements()) {
            applyInstrToId(instr, v.nextElement());
          }
          Enumeration<Integer> i = images.keys();
          while (i.hasMoreElements()) {
            applyInstrToId(instr, i.nextElement());
          }
        }
        else if (!instr.hasKey("id")) {
          println("[error] ID is required");
        } else {
          applyInstrToId(instr, instr.getInt("id"));
        }
      }
    }
  }

  void drawBackground() {
    image(backImage, 0, 0);
  }

  void drawAll() {
    // Draw all videos
    Enumeration<Video> v = videos.elements();
    while (v.hasMoreElements()) {
      v.nextElement().draw();
    }

    // Draw all images
    Enumeration<Image> i = images.elements();
    while (i.hasMoreElements()) {
      i.nextElement().draw();
    }
  }

  void applyInstrToId(JSONObject instr, int id) {
    if (instr.getString("method").equals("create")) {
      if (instr.hasKey("image")) {
        createImage(instr);
      } else if (instr.hasKey("video")) {
        createVideo(instr);
      }
    }
    else if (instr.getString("method").equals("update")) {
      if (images.containsKey(id)) {
        updateImage(instr, id);
      } else if (videos.containsKey(id)) {
        updateVideo(instr, id);
      } else {
        println("[error] Invalid ID: "+id);
      }
    }
    else if (instr.getString("method").equals("delete")) {
      if (images.containsKey(id)) {
        deleteImage(instr, id);
      } else if (videos.containsKey(id)) {
        deleteVideo(instr, id);
      } else {
        println("[error] Invalid ID: "+id);
      }
    }
  }

  void createImage(JSONObject instr) {
    int posX = instr.hasKey("posX") ? instr.getInt("posX") : 0;
    int posY = instr.hasKey("posY") ? instr.getInt("posY") : 0;
    String filename = instr.getString("image");

    File f = new File(dataPath(filename));
    if (f.exists()) {
      Image img = new Image(filename, posX, posY);
      images.put(instr.getInt("id"), img);
    } else {
      println("[error] File "+filename+" does not exist");
    }
  }

  void createVideo(JSONObject instr) {
    int posX = instr.hasKey("posX") ? instr.getInt("posX") : 0;
    int posY = instr.hasKey("posY") ? instr.getInt("posY") : 0;
    String filename = instr.getString("video");

    File f = new File(dataPath(filename));
    if (f.exists()) {
      Video vid = new Video(filename, posX, posY);
      videos.put(instr.getInt("id"), vid);
    } else {
      println("[error] File "+filename+" does not exist");
    }
  }

  void deleteImage(JSONObject instr, Integer id) {
    images.remove(id);
  }
  
  void deleteVideo(JSONObject instr, Integer id) {
    videos.remove(id);
  }

  void updateImage(JSONObject instr, Integer id) {
    Image img = images.get(id);

    if (instr.hasKey("width") && instr.hasKey("height")) {
      img.updateSize(instr.getInt("width"), instr.getInt("height"));
    }
    
    if (instr.hasKey("brightness")) {
      img.startBrightness(instr.getInt("brightness"), instr.getInt("totaltime"), instr.getInt("numupdates"));
    }

    if (instr.hasKey("threshold")) {
      img.threshold(instr.getFloat("threshold"));
    }

    if (instr.hasKey("transparency")) {
      img.startTransparency(instr.getInt("transparency"), instr.getInt("totaltime"), instr.getInt("numupdates"));
    }

    if (instr.hasKey("adjustHue")) {
      img.startHue(instr.getInt("red"), instr.getInt("green"), instr.getInt("blue"), instr.getInt("totaltime"), instr.getInt("numupdates"));
    }

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

  void updateVideo(JSONObject instr, Integer id) {
    Video vid = videos.get(id);

    if (instr.hasKey("easing")) {
      vid.setEasing(instr.getFloat("easing"));
      vid.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
    }
  }
};
