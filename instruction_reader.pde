class InstructionReader implements Runnable {
  JSONArray instructions;
  ConcurrentLinkedQueue<JSONObject> queue;
  int instructionCounter = 0;

  InstructionReader(ConcurrentLinkedQueue<JSONObject> queue, String sampleInstructionFile) {
    this.queue = queue;
    instructions = loadJSONArray(sampleInstructionFile);
  }

  String getDeviceId() {
    if (instructions.getJSONObject(0).hasKey("deviceId")) {
      return instructions.getJSONObject(0).getString("deviceId");
    }
    return "";
  }

  void run() {
    try {
      JSONObject instr;

      while (instructionCounter < instructions.size()) {
        instr = instructions.getJSONObject(instructionCounter++);
        if (!instr.hasKey("sleep")) {
          instr.setInt("sleep", 1000);
        }
        queue.add(instr);
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
};
