JSONObject VIPER_CONFIG;

String configFilename = "config.json";

void customGUI() {
  File f = new File(dataPath(configFilename));
  if (f.exists()) {
    VIPER_CONFIG = loadJSONObject(configFilename);
  } else {
    VIPER_CONFIG = loadJSONObject("config/default_config.json");
    saveJSONObject(VIPER_CONFIG, dataPath(configFilename));
  }
  populateFieldsFromJSON();
  
  version_label.setText("Version: "+VERSION);
  if (!TESTMODE) {
    String myWAN = NetInfo.wan();
    ip.setText(myWAN);
  }
}

void populateFieldsFromJSON() {
  if (VIPER_CONFIG.getBoolean("verboseLog")) {
    verbose_log.setSelected(true);
  } else {
    verbose_log.setSelected(false);
  }
  if (VIPER_CONFIG.getBoolean("record")) {
    record.setSelected(true);
  } else {
    record.setSelected(false);
  }
  if (VIPER_CONFIG.getBoolean("testMode")) {
    test_mode.setSelected(true);
  } else {
    test_mode.setSelected(false);
  }
  port.setText(Integer.toString(VIPER_CONFIG.getInt("port")));
  num_ports.setText(Integer.toString(VIPER_CONFIG.getInt("numberPorts")));
  widthfield1.setText(Integer.toString(VIPER_CONFIG.getInt("width")));
  aspectW.setText(Integer.toString(VIPER_CONFIG.getInt("aspectWidth")));
  aspectH.setText(Integer.toString(VIPER_CONFIG.getInt("aspectHeight")));

  test_file_1.setText(VIPER_CONFIG.getString("testFile1"));
  test_file_2.setText(VIPER_CONFIG.getString("testFile2"));
  test_file_3.setText(VIPER_CONFIG.getString("testFile3"));
  rdevices.setText(VIPER_CONFIG.getString("deviceIds"));
}

void populateGlobals() {
  TESTMODE = test_mode.isSelected();
  RECORD = record.isSelected();
  VERBOSE_LOG = verbose_log.isSelected();

  PORT = Integer.parseInt(port.getText().trim());
  NUM_PORTS = Integer.parseInt(num_ports.getText().trim());

  WIDTH = Integer.parseInt(widthfield1.getText().trim());
  ASPECT_RATIO_W = Integer.parseInt(aspectW.getText().trim());
  ASPECT_RATIO_H = Integer.parseInt(aspectH.getText().trim());

  REGISTERED_DEVICES = rdevices.getText().trim().split("\\s*,\\s*");
}

void populateJSONFromFields() {
  VIPER_CONFIG.setBoolean("verboseLog", VERBOSE_LOG);
  VIPER_CONFIG.setBoolean("record", RECORD);
  VIPER_CONFIG.setBoolean("testMode", TESTMODE);
  VIPER_CONFIG.setInt("port", PORT);
  VIPER_CONFIG.setInt("numberPorts", NUM_PORTS);
  VIPER_CONFIG.setInt("width", WIDTH);
  VIPER_CONFIG.setInt("aspectWidth", ASPECT_RATIO_W);
  VIPER_CONFIG.setInt("aspectHeight", ASPECT_RATIO_H);
  VIPER_CONFIG.setString("testFile1", test_file_1.getText().trim());
  VIPER_CONFIG.setString("testFile2", test_file_2.getText().trim());
  VIPER_CONFIG.setString("testFile3", test_file_3.getText().trim());
  VIPER_CONFIG.setString("deviceIds", rdevices.getText().trim());

  saveJSONObject(VIPER_CONFIG, dataPath(configFilename));
}

void removeGUI() {
  run.dispose(); 
  test_mode.dispose(); 
  record.dispose(); 
  label1.dispose(); 
  ip_label.dispose(); 
  port_label.dispose(); 
  num_port_label.dispose(); 
  num_ports.dispose(); 
  port.dispose(); 
  ip.dispose(); 
  test_file_1.dispose(); 
  test_file_2.dispose(); 
  test_file_label.dispose(); 
  test_file_3.dispose(); 
  verbose_log.dispose(); 
  aspect_ratio_label.dispose(); 
  width_label.dispose(); 
  widthfield1.dispose(); 
  rdevices.dispose(); 
  rdevice_label.dispose(); 
  version_label.dispose(); 
  aspectW.dispose(); 
  aspectH.dispose(); 
  label2.dispose(); 
}

