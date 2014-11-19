class InstructionReader implements Runnable {
  JSONArray instructions;
  ConcurrentLinkedQueue<JSONObject> queue;
  int instructionCounter = 0;

  InstructionReader(ConcurrentLinkedQueue<JSONObject> queue, String sampleInstructionFile) {
    this.queue = queue;
    instructions = loadJSONArray(sampleInstructionFile);
  }

  void run() {
    try {
      JSONObject instr;

      while (instructionCounter < instructions.size()) {
        instr = instructions.getJSONObject(instructionCounter++);
        queue.add(instr);

        if (!instr.hasKey("sleep")) {
          Thread.currentThread().sleep(1000);
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
};
