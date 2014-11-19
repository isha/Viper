class Channel implements Runnable {
  Hashtable<Integer, Image> images;
  Hashtable<Integer, Video> videos;
  Hashtable<Integer, AnimatedGif> gifs;

  Image backImage;
  int backImageId;

  AnimatedGif backGif;
  int backGifId;

  Video backVideo;
  int backVideoId;

  String textStr;
  int textPosX;
  int textPosY;

  long currentTime;

  ConcurrentLinkedQueue<JSONObject> queue;
  
  Channel(ConcurrentLinkedQueue<JSONObject> queue) {
    images = new Hashtable<Integer, Image>();
    videos = new Hashtable<Integer, Video>();
    gifs = new Hashtable<Integer, AnimatedGif>();
    backGifId = backImageId = backVideoId = -1;

    size(WIDTH, HEIGHT);

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
      }

    }
  }

  void drawBackground() {
    if (backImage != null) {
      image(backImage.getPImage(), 0, 0, WIDTH, HEIGHT);
    } else if (backGif != null) {
      image(backGif.getGif(), 0, 0, WIDTH, HEIGHT);
    } else if (backVideo != null) {
      image(backVideo.getMovie(), 0, 0, WIDTH, HEIGHT);
    }
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

    // Draw all gifs
    Enumeration<AnimatedGif> g = gifs.elements();
    while (g.hasMoreElements()) {
      g.nextElement().draw();
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
      if (instr.hasKey("background")) {
        setBackground(instr);
      } else if (instr.hasKey("image")) {
        createImage(instr);
      } else if (instr.hasKey("video")) {
        createVideo(instr);
      } else {
        println("[error] image or video key required when creating");
      }
    }
    else if (instr.getString("method").equals("update")) {
      if (images.containsKey(id) || backImageId == id) {
        updateImage(instr, id);
      } else if (gifs.containsKey(id) || backGifId == id) {
        updateGif(instr, id);
      } else if (videos.containsKey(id) || backVideoId == id) {
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

  void setBackground(JSONObject instr) {
    backGif = null;
    backImage = null;
    backVideo = null;
    backGifId = backImageId = backVideoId = -1;

    if (instr.hasKey("image")) {
      String filename = instr.getString("image");
      File f = new File(dataPath(filename));
      if (f.exists()) {
        if (filename.endsWith(".gif")) {
          AnimatedGif gif = new AnimatedGif(filename, 0, 0);
          backGif = gif; backGifId = instr.getInt("id");
        } else {
          Image img = new Image(filename, 0, 0);
          backImage = img; backImageId = instr.getInt("id");
        }
      } else {
        println("[error] File "+filename+" does not exist");
      }
    } else if (instr.hasKey("video")) {
      String filename = instr.getString("video");

      File f = new File(dataPath(filename));
      if (f.exists()) {
        Video vid = new Video(filename, 0, 0);
        backVideo = vid; backVideoId = instr.getInt("id");
      } else {
        println("[error] File "+filename+" does not exist");
      }
    }
  }

  void createImage(JSONObject instr) {
    int posX = instr.hasKey("posX") ? instr.getInt("posX") : 0;
    int posY = instr.hasKey("posY") ? instr.getInt("posY") : 0;
    String filename = instr.getString("image");

    File f = new File(dataPath(filename));
    if (f.exists()) {
      if (filename.endsWith(".gif")) {
        AnimatedGif gif = new AnimatedGif(filename, posX, posY);
        gifs.put(instr.getInt("id"), gif);
      } else {
        Image img = new Image(filename, posX, posY);
        images.put(instr.getInt("id"), img);
      }
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

  void deleteGif(JSONObject instr, Integer id) {
    gifs.remove(id);
  }
  
  void deleteVideo(JSONObject instr, Integer id) {
    videos.remove(id);
  }

  void updateImage(JSONObject instr, Integer id) {
    Image img;
    if (backImageId ==  id) {
      img = backImage;
    } else {
      img = images.get(id);
    }

    if (instr.hasKey("width") && instr.hasKey("height")) {
      img.updateSize(instr.getInt("width"), instr.getInt("height"));
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

    if (instr.hasKey("easing")) {
      if (instr.hasKey("endX") && instr.hasKey("endY")) {
        img.setEasing(instr.getFloat("easing"));
        img.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));        
      }
      else {
        println("[error] Missing or incorrect parameters in easing instruction");
      }
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

  void updateGif(JSONObject instr, Integer id) {
    AnimatedGif gif;
    if (backGifId == id) {
      gif = backGif;
    } else {
      gif = gifs.get(id);
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

    if (instr.hasKey("easing")) {
      if (instr.hasKey("endX") && instr.hasKey("endY")) {
        gif.setEasing(instr.getFloat("easing"));
        gif.updateTargetPostion(instr.getInt("endX"), instr.getInt("endY"));
      }
      else {
        println("[error] Missing or incorrect parameters in easing instruction");
      }
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
  }

  void updateVideo(JSONObject instr, Integer id) {
    Video vid;
    if (backVideoId ==  id) {
      vid = backVideo;
    } else {
      vid = videos.get(id);
    }

    if (instr.hasKey("easing")) {
      vid.setEasing(instr.getFloat("easing"));
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

  }
};
