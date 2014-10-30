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
    
    JSONObject instr;
    instr = queue.poll();

    // Run instruction if pending in queue
    if (instr != null) {
      if (instr.getString("method").equals("create")) {
        Image img = new Image(instr.getString("image"), instr.getInt("posX"), instr.getInt("posY"));

        if (instr.hasKey("id")) {
          images.put(instr.getInt("id"), img);
        } else {
          println("[error] Cannot create image "+instr.getString("image")+" since id is not provided");
        }
      }
      else if (instr.getString("method").equals("update")) {
        if (!instr.hasKey("id")) {
          println("[error] Cannot update without id");
        } else if (!images.containsKey(instr.getInt("id"))) {
          println("[error] Invalid id: "+instr.getInt("id"));
        } else {
          Image img = images.get(instr.getInt("id"));

          if (instr.hasKey("width") && instr.hasKey("height")) {
            img.updateSize(instr.getInt("width"), instr.getInt("height"));
          }
          
          if (instr.hasKey("brightness")) {
            img.setBrightness(instr.getInt("brightness"));
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

          if (instr.hasKey("transparency")) {
            img.setTransparency(instr.getInt("transparency"));
          }
        }
      }
      else if (instr.getString("method").equals("delete")) {
        if (!instr.hasKey("id")) {
          println("[error] Cannot delete without id");
        } else if (!images.containsKey(instr.getInt("id"))) {
          println("[error] Invalid id: "+instr.getInt("id"));
        } else {
          images.remove(instr.getInt("id"));
        }
      }
    }

    // Draw all images
    Enumeration<Image> e = images.elements();
    while (e.hasMoreElements()) {
      e.nextElement().draw();
    }
  }
};
