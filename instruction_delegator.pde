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
            for (ConcurrentLinkedQueue<JSONObject> channelQueue : queues.values()) {
              channelQueue.add(instr);
            }

            if (RECORD) {
              String message = instr.toString();
              PrintWriter r = recorders.get("master");
              r.println(message);
              r.flush();
            }
          }
          else if (instr.hasKey("deviceId")) {
            String id = instr.getString("deviceId");

            if (queues.containsKey(id)) {
              ConcurrentLinkedQueue<JSONObject> channelQueue = queues.get(id);
              channelQueue.add(instr);

              if (RECORD) {
                String message = instr.toString();
                PrintWriter r = recorders.get(id);
                r.println(message);
                r.flush();
              }

            } else {
              println("[error] Invalid device ID: "+id);
            }
          } else { println("[error] Device ID not provided"); }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
};
