class InstructionDelegator implements Runnable {
  ConcurrentLinkedQueue<JSONObject> queue;

  InstructionDelegator(ConcurrentLinkedQueue<JSONObject> queue) {
    this.queue = queue;
  }

  void run() {
    try {
      while (true) {
        JSONObject instr;
        instr = queue.poll();

        if (instr != null) {
          if (instr.hasKey("master")) {
            Enumeration<ConcurrentLinkedQueue<JSONObject>> channelQueue = queues.elements();
            while (channelQueue.hasMoreElements()) {
              channelQueue.nextElement().add(instr);
            }
          }
          else if (instr.hasKey("deviceId")) {
            String id = instr.getString("deviceId");

            if (queues.containsKey(id)) {
              ConcurrentLinkedQueue<JSONObject> channelQueue = queues.get(id);
              channelQueue.add(instr);
            } else {
              println("[error] Invalid device ID: "+id);
            }
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
};
