class Channel {
  JSONArray instructions;
  Integer instructionPointer;

  Channel() {
    instructionPointer = 0;
  }

  void setInstructions(JSONArray instrs) {
    this.instructions = instrs;
  }

  boolean nextInstructionExists() {
    return instructionPointer < instructions.size();
  }

  JSONObject nextInstruction() {
    return instructions.getJSONObject(instructionPointer++);
  }
};

