class Channel implements Runnable {
  ConcurrentHashMap<Integer, Image> images;
  ConcurrentHashMap<Integer, Video> videos;
  ConcurrentHashMap<Integer, AnimatedGif> gifs;

  ConcurrentSkipListMap<Integer, MediaType> mapping;

  String textStr;
  int textPosX;
  int textPosY;

  long currentTime;
  long timerStart;
  long timer;

  ConcurrentLinkedQueue<JSONObject> queue;
  
  Channel(ConcurrentLinkedQueue<JSONObject> queue) {
    images = new ConcurrentHashMap<Integer, Image>();
    videos = new ConcurrentHashMap<Integer, Video>();
    gifs = new ConcurrentHashMap<Integer, AnimatedGif>();
    mapping = new ConcurrentSkipListMap<Integer, MediaType>();

    this.queue = queue;
  }

  void run() {
    while (true) {
      if (timer != 0 && System.currentTimeMillis() - timerStart < timer) {
        continue;
      } 
      timer = 0;

      JSONObject instr;
      instr = queue.poll();

      // Run instruction if pending in queue

      if (instr != null) {
        if (instr.hasKey("master")) {
          for (Integer key : videos.keySet()) {
            applyInstrToId(instr, key);
          }
          for (Integer key : images.keySet()) {
            applyInstrToId(instr, key);
          }
          for (Integer key : gifs.keySet()) {
            applyInstrToId(instr, key);
          }
        } 
        else if (!instr.hasKey("id")) {
          if (instr.hasKey("text")) {
            textStr = instr.getString("text");
            textPosX = instr.getInt("textPosX");
            textPosY = instr.getInt("textPosY");
          } else {
            println("[error] ID is required");
          }
        } else {
          applyInstrToId(instr, instr.getInt("id"));
        }

        if (instr.hasKey("sleep")) {
          timerStart = System.currentTimeMillis();
          timer = instr.getInt("sleep");
        }
      }

    }
  }

  void drawAll() {
    // Draw all objects
    for (Entry<Integer, MediaType> entry : mapping.entrySet()) {
      Integer id = entry.getKey();
      MediaType type = entry.getValue();

      switch (type) {
        case IMAGE: Image img = images.get(id); img.draw(); break;
        case ANIMATEDGIF: AnimatedGif gif = gifs.get(id); gif.draw(); break;
        case VIDEO: Video vid = videos.get(id); vid.draw(); break;
      }
    }

    // Draw all text
    if (textStr != null) {
      text(textStr, textPosX, textPosY);
    }
  }

  void applyInstrToId(JSONObject instr, int id) {
    if (instr.hasKey("text")) {
      textStr = instr.getString("text");
      textPosX = instr.getInt("textPosX");
      textPosY = instr.getInt("textPosY");
    }

    if (instr.getString("method").equals("create")) {
      if (instr.hasKey("image")) {
        createImage(instr);
      } else if (instr.hasKey("video")) {
        createVideo(instr);
      } else {
        println("[error] image or video key required when creating");
      }
    }
    else if (instr.getString("method").equals("update")) {
      if (images.containsKey(id)) {
        updateImage(instr, id);
      } else if (gifs.containsKey(id)) {
        updateGif(instr, id);
      } else if (videos.containsKey(id)) {
        updateVideo(instr, id);
      } else {
        println("[error] Invalid ID: "+id+" for update");
      }
    }
    else if (instr.getString("method").equals("delete")) {
      if (images.containsKey(id)) {
        deleteImage(instr, id);
      } else if (gifs.containsKey(id)) {
        deleteGif(instr, id); 
      } else if (videos.containsKey(id)) {
        deleteVideo(instr, id);
      } else {
        println("[error] Invalid ID: "+id+" for delete");
      }
    }
  }

  void createImage(JSONObject instr) {
    float posX = instr.hasKey("posX") ? instr.getFloat("posX") : 0;
    float posY = instr.hasKey("posY") ? instr.getFloat("posY") : 0;
    String filename = instr.getString("image");
    boolean h = false;
    if (instr.hasKey("hidden")) {
      h = instr.getBoolean("hidden");
    }

    File f = new File(dataPath(filename));
    if (f.exists()) {
      if (filename.endsWith(".gif")) {
        AnimatedGif gif = new AnimatedGif(filename, posX, posY, true);
        gifs.put(instr.getInt("id"), gif);
        mapping.put(instr.getInt("id"), MediaType.ANIMATEDGIF);
        instr.setBoolean("hidden", h);
        updateGif(instr, instr.getInt("id"));
      } else {
        Image img = new Image(filename, posX, posY, true);
        images.put(instr.getInt("id"), img);
        mapping.put(instr.getInt("id"), MediaType.IMAGE);
        instr.setBoolean("hidden", h);
        updateImage(instr, instr.getInt("id"));
      }
    } else {
      println("[error] File "+filename+" does not exist");
    }
  }

  void createVideo(JSONObject instr) {
    float posX = instr.hasKey("posX") ? instr.getFloat("posX") : 0;
    float posY = instr.hasKey("posY") ? instr.getFloat("posY") : 0;
    String filename = instr.getString("video");
    boolean h = false;
    if (instr.hasKey("hidden")) {
      h = instr.getBoolean("hidden");
    }

    File f = new File(dataPath(filename));
    if (f.exists()) {
      Video vid = new Video(filename, posX, posY, true);
      videos.put(instr.getInt("id"), vid);
      mapping.put(instr.getInt("id"), MediaType.VIDEO);
      instr.setBoolean("hidden", h);
      updateVideo(instr, instr.getInt("id"));
    } else {
      println("[error] File "+filename+" does not exist");
    }
  }

  void deleteImage(JSONObject instr, Integer id) {
    images.remove(id);
    mapping.remove(id);
  }

  void deleteGif(JSONObject instr, Integer id) {
    gifs.remove(id);
    mapping.remove(id);
  }
  
  void deleteVideo(JSONObject instr, Integer id) {
    videos.remove(id);
    mapping.remove(id);
  }

  void updateImage(JSONObject instr, Integer id) {
    Image img = images.get(id);

    if (instr.hasKey("reset")) {
      img.reset();
    }

    if (instr.hasKey("width") && instr.hasKey("height")) {
      img.updateSize(instr.getFloat("width"), instr.getFloat("height"));
    }

    if (instr.hasKey("scale")) {
      img.setScale(instr.getInt("scale"));
    }
    
    if (instr.hasKey("brightness")) {
      if (instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        img.startBrightness(instr.getInt("brightness"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in brightness instruction");
      }
    }

    if (instr.hasKey("threshold")) {
      img.threshold(instr.getFloat("threshold"));
    }

    if (instr.hasKey("transparency")) {
      if (instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        img.startTransparency(instr.getInt("transparency"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in transparency instruction");
      }
    }

    if (instr.hasKey("setTransparency")) {
      img.setTransparency(instr.getInt("setTransparency"));
    }

    if (instr.hasKey("hue")) {
      if (instr.hasKey("red") && instr.hasKey("green") && instr.hasKey("blue") && instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        img.startHue(instr.getInt("red"), instr.getInt("green"), instr.getInt("blue"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in hue instruction");
      }
    }

    if (instr.hasKey("setRed")) {
      img.setRed(instr.getInt("setRed"));
    }    

    if (instr.hasKey("setGreen")) {
      img.setGreen(instr.getInt("setGreen"));
    }    

    if (instr.hasKey("setBlue")) {
      img.setBlue(instr.getInt("setBlue"));
    }    

    if (instr.hasKey("setBrightness")) {
      img.setBrightness(instr.getInt("setBrightness"));
    }

    if (instr.hasKey("easing")) {
      img.setEasing(instr.getFloat("easing"));       
    }

    if (instr.hasKey("endX") && instr.hasKey("endY")) {
      img.updateTargetPostion(instr.getFloat("endX"), instr.getFloat("endY"));
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

    if (instr.hasKey("rotate")) {
      img.setRotation(instr.getInt("rotate"));
    }

    if (instr.hasKey("hidden")) {
      img.setHidden(instr.getBoolean("hidden"));
    }
  }

  void updateGif(JSONObject instr, Integer id) {
    AnimatedGif gif = gifs.get(id);

    if (instr.hasKey("scale")) {
      gif.setScale(instr.getInt("scale"));
    }

    if (instr.hasKey("width") && instr.hasKey("height")) {
      gif.updateSize(instr.getFloat("width"), instr.getFloat("height"));
    }

    if (instr.hasKey("transparency")) {
      if (instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        gif.startTransparency(instr.getInt("transparency"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in transparency instruction");
      }
    }

    if (instr.hasKey("setTransparency")) {
      gif.setTransparency(instr.getInt("setTransparency"));
    }
    
    if (instr.hasKey("brightness")) {
      if (instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        gif.startBrightness(instr.getInt("brightness"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in brightness instruction");
      }
    }

    if (instr.hasKey("threshold")) {
      gif.threshold(instr.getFloat("threshold"));
    }

    if (instr.hasKey("hue")) {
      if (instr.hasKey("red") && instr.hasKey("green") && instr.hasKey("blue") && instr.hasKey("totaltime") && instr.hasKey("numupdates")) {
        gif.startHue(instr.getInt("red"), instr.getInt("green"), instr.getInt("blue"), instr.getInt("totaltime"), instr.getInt("numupdates"));
      }
      else {
        println("[error] Missing or incorrect parameters in hue instruction");
      }
    }

    if (instr.hasKey("setRed")) {
      gif.setRed(instr.getInt("setRed"));
    }    

    if (instr.hasKey("setGreen")) {
      gif.setGreen(instr.getInt("setGreen"));
    }    

    if (instr.hasKey("setBlue")) {
      gif.setBlue(instr.getInt("setBlue"));
    }    

    if (instr.hasKey("setBrightness")) {
      gif.setBrightness(instr.getInt("setBrightness"));
    }

    if (instr.hasKey("easing")) {
      gif.setEasing(instr.getFloat("easing"));
    }

    if (instr.hasKey("endX") && instr.hasKey("endY")) {
      gif.updateTargetPostion(instr.getFloat("endX"), instr.getFloat("endY"));
    }

    if (instr.hasKey("blur")) {
      gif.blur(instr.getInt("blur"));
    }

    if (instr.hasKey("gray")) {
      gif.gray();
    }

    if (instr.hasKey("invert")) {
      gif.invert();
    }

    if (instr.hasKey("posterize")) {
      gif.posterize(instr.getInt("posterize"));
    }

    if (instr.hasKey("erode")) {
      gif.erode();
    }

    if (instr.hasKey("dilate")) {
      gif.dilate();
    }

    if (instr.hasKey("threshold")) {
      gif.threshold(instr.getFloat("threshold"));
    }

    if (instr.hasKey("hidden")) {
      gif.setHidden(instr.getBoolean("hidden"));
    }
  }

  void updateVideo(JSONObject instr, Integer id) {
    Video vid = (Video) videos.get(id);

    if (instr.hasKey("pause")) {
      vid.pausePlayback();
    }
    if (instr.hasKey("resume")) {
      vid.resumePlayback();
    }

    if (instr.hasKey("scale")) {
      vid.setScale(instr.getInt("scale"));
    }

    if (instr.hasKey("width") && instr.hasKey("height")) {
      vid.updateSize(instr.getFloat("width"), instr.getFloat("height"));
    }

    if (instr.hasKey("easing")) {
      vid.setEasing(instr.getFloat("easing"));
    }

    if (instr.hasKey("endX") && instr.hasKey("endY")) {
      vid.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
    }

    if (instr.hasKey("reverse")) {
      if (instr.hasKey("speed")) {
        vid.setPlaybackSpeed(instr.getFloat("speed"));
      } 
      vid.setReversePlaybackSpeed();
      vid.updatePlaybackSpeed();
    }

    if (instr.hasKey("speed")) {
      vid.setPlaybackSpeed(instr.getFloat("speed"));
      vid.updatePlaybackSpeed();
    } 

    if (instr.hasKey("hidden")) {
      vid.setHidden(instr.getBoolean("hidden"));
    }

  }
};
