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
        println("Added instruction: "+instructionCounter);
        instr = instructions.getJSONObject(instructionCounter++);
        queue.add(instr);

        Thread.currentThread().sleep(1000);
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
};
