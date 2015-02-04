/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void run_click1(GButton source, GEvent event) { //_CODE_:run:570473:
  runViper();
} //_CODE_:run:570473:

public void test_mode_clicked1(GCheckbox source, GEvent event) { //_CODE_:test_mode:461620:

} //_CODE_:test_mode:461620:

public void record_clicked1(GCheckbox source, GEvent event) { //_CODE_:record:415747:

} //_CODE_:record:415747:

public void num_ports_change1(GTextField source, GEvent event) { //_CODE_:num_ports:992607:

} //_CODE_:num_ports:992607:

public void port_change1(GTextField source, GEvent event) { //_CODE_:port:619840:

} //_CODE_:port:619840:

public void test_file_1_change1(GTextField source, GEvent event) { //_CODE_:test_file_1:472951:

} //_CODE_:test_file_1:472951:

public void test_file_2_change1(GTextField source, GEvent event) { //_CODE_:test_file_2:350529:

} //_CODE_:test_file_2:350529:

public void test_file_3_change1(GTextField source, GEvent event) { //_CODE_:test_file_3:536373:

} //_CODE_:test_file_3:536373:

public void verbose_log_clicked1(GCheckbox source, GEvent event) { //_CODE_:verbose_log:692881:

} //_CODE_:verbose_log:692881:

public void widthfield1_change1(GTextField source, GEvent event) { //_CODE_:widthfield1:228917:

} //_CODE_:widthfield1:228917:

public void rdevices_change1(GTextArea source, GEvent event) { //_CODE_:rdevices:779202:
  
} //_CODE_:rdevices:779202:

public void aspectW_change1(GTextField source, GEvent event) { //_CODE_:aspectW:681718:
} //_CODE_:aspectW:681718:

public void aspectH_change1(GTextField source, GEvent event) { //_CODE_:aspectH:728375:
} //_CODE_:aspectH:728375:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Viper");
  run = new GButton(this, 20, 340, 120, 40);
  run.setText("Run");
  run.setTextBold();
  run.addEventHandler(this, "run_click1");
  test_mode = new GCheckbox(this, 20, 140, 130, 20);
  test_mode.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  test_mode.setText(" Test Mode");
  test_mode.setOpaque(false);
  test_mode.addEventHandler(this, "test_mode_clicked1");
  record = new GCheckbox(this, 20, 80, 130, 20);
  record.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  record.setText(" Record");
  record.setOpaque(false);
  record.addEventHandler(this, "record_clicked1");
  label1 = new GLabel(this, 10, 10, 100, 40);
  label1.setText("Viper");
  label1.setTextBold();
  label1.setOpaque(false);
  ip_label = new GLabel(this, 160, 80, 130, 20);
  ip_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  ip_label.setText("IP Address");
  ip_label.setOpaque(false);
  port_label = new GLabel(this, 160, 110, 130, 20);
  port_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  port_label.setText("Port");
  port_label.setOpaque(false);
  num_port_label = new GLabel(this, 160, 140, 130, 20);
  num_port_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  num_port_label.setText("Number of Ports");
  num_port_label.setOpaque(false);
  num_ports = new GTextField(this, 300, 140, 140, 20, G4P.SCROLLBARS_NONE);
  num_ports.setText("1");
  num_ports.setOpaque(true);
  num_ports.addEventHandler(this, "num_ports_change1");
  port = new GTextField(this, 300, 110, 140, 20, G4P.SCROLLBARS_NONE);
  port.setText("11000");
  port.setOpaque(true);
  port.addEventHandler(this, "port_change1");
  ip = new GLabel(this, 300, 80, 140, 20);
  ip.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  ip.setText("N/A");
  ip.setOpaque(false);
  test_file_1 = new GTextField(this, 20, 200, 130, 20, G4P.SCROLLBARS_NONE);
  test_file_1.setText("demo/instructions1.json");
  test_file_1.setOpaque(true);
  test_file_1.addEventHandler(this, "test_file_1_change1");
  test_file_2 = new GTextField(this, 20, 230, 130, 20, G4P.SCROLLBARS_NONE);
  test_file_2.setText("demo/instructions2.json");
  test_file_2.setOpaque(true);
  test_file_2.addEventHandler(this, "test_file_2_change1");
  test_file_label = new GLabel(this, 20, 170, 130, 20);
  test_file_label.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  test_file_label.setText(" Enter test files below");
  test_file_label.setOpaque(false);
  test_file_3 = new GTextField(this, 20, 260, 130, 20, G4P.SCROLLBARS_NONE);
  test_file_3.setText("demo/instructions3.json");
  test_file_3.setOpaque(true);
  test_file_3.addEventHandler(this, "test_file_3_change1");
  verbose_log = new GCheckbox(this, 20, 110, 130, 20);
  verbose_log.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  verbose_log.setText(" Verbose Log");
  verbose_log.setOpaque(false);
  verbose_log.addEventHandler(this, "verbose_log_clicked1");
  verbose_log.setSelected(true);
  aspect_ratio_label = new GLabel(this, 210, 200, 80, 20);
  aspect_ratio_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  aspect_ratio_label.setText("Aspect Ratio");
  aspect_ratio_label.setOpaque(false);
  width_label = new GLabel(this, 210, 170, 80, 20);
  width_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  width_label.setText("Width");
  width_label.setOpaque(false);
  widthfield1 = new GTextField(this, 300, 170, 140, 20, G4P.SCROLLBARS_NONE);
  widthfield1.setText("1000");
  widthfield1.setOpaque(true);
  widthfield1.addEventHandler(this, "widthfield1_change1");
  rdevices = new GTextArea(this, 300, 260, 140, 110, G4P.SCROLLBARS_NONE);
  rdevices.setOpaque(true);
  rdevices.addEventHandler(this, "rdevices_change1");
  rdevice_label = new GLabel(this, 170, 258, 120, 45);
  rdevice_label.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  rdevice_label.setText("Comma separated Registered device IDs");
  rdevice_label.setOpaque(false);
  version_label = new GLabel(this, 120, 20, 130, 20);
  version_label.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  version_label.setOpaque(false);
  aspectW = new GTextField(this, 300, 200, 50, 20, G4P.SCROLLBARS_NONE);
  aspectW.setText("1");
  aspectW.setOpaque(true);
  aspectW.addEventHandler(this, "aspectW_change1");
  aspectH = new GTextField(this, 390, 200, 50, 20, G4P.SCROLLBARS_NONE);
  aspectH.setText("1");
  aspectH.setOpaque(true);
  aspectH.addEventHandler(this, "aspectH_change1");
  label2 = new GLabel(this, 350, 200, 40, 20);
  label2.setText("by");
  label2.setOpaque(false);
}

// Variable declarations 
// autogenerated do not edit
GButton run; 
GCheckbox test_mode; 
GCheckbox record; 
GLabel label1; 
GLabel ip_label; 
GLabel port_label; 
GLabel num_port_label; 
GTextField num_ports; 
GTextField port; 
GLabel ip; 
GTextField test_file_1; 
GTextField test_file_2; 
GLabel test_file_label; 
GTextField test_file_3; 
GCheckbox verbose_log; 
GLabel aspect_ratio_label; 
GLabel width_label; 
GTextField widthfield1; 
GTextArea rdevices; 
GLabel rdevice_label; 
GLabel version_label; 
GTextField aspectW; 
GTextField aspectH; 
GLabel label2; 

