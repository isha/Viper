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
  HEIGHT = Integer.parseInt(p_win_height.getText().trim());
  WIDTH = Integer.parseInt(p_win_width.getText().trim());
  PORT = Integer.parseInt(port.getText().trim());
  NUM_PORTS = Integer.parseInt(num_ports.getText().trim());

  runViper();
} //_CODE_:run:570473:

public void test_mode_clicked1(GCheckbox source, GEvent event) { //_CODE_:test_mode:461620:

  TESTMODE = !TESTMODE;
} //_CODE_:test_mode:461620:

public void record_clicked1(GCheckbox source, GEvent event) { //_CODE_:record:415747:

  RECORD = !RECORD;
} //_CODE_:record:415747:

public void p_win_height_change1(GTextField source, GEvent event) { //_CODE_:p_win_height:586132:

} //_CODE_:p_win_height:586132:

public void p_win_width_change1(GTextField source, GEvent event) { //_CODE_:p_win_width:577060:

} //_CODE_:p_win_width:577060:

public void num_ports_change1(GTextField source, GEvent event) { //_CODE_:num_ports:992607:

} //_CODE_:num_ports:992607:

public void port_change1(GTextField source, GEvent event) { //_CODE_:port:619840:

} //_CODE_:port:619840:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Viper");
  run = new GButton(this, 320, 265, 120, 40);
  run.setText("Run");
  run.setTextBold();
  run.addEventHandler(this, "run_click1");
  test_mode = new GCheckbox(this, 15, 110, 130, 20);
  test_mode.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  test_mode.setText(" Test Mode");
  test_mode.setOpaque(false);
  test_mode.addEventHandler(this, "test_mode_clicked1");
  record = new GCheckbox(this, 15, 80, 130, 20);
  record.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  record.setText(" Record");
  record.setOpaque(false);
  record.addEventHandler(this, "record_clicked1");
  label1 = new GLabel(this, 15, 15, 120, 40);
  label1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label1.setText("Viper");
  label1.setTextBold();
  label1.setOpaque(false);
  p_win_height = new GTextField(this, 65, 180, 80, 20, G4P.SCROLLBARS_NONE);
  p_win_height.setText("600");
  p_win_height.setPromptText("100");
  p_win_height.setOpaque(true);
  p_win_height.addEventHandler(this, "p_win_height_change1");
  p_win_width = new GTextField(this, 65, 150, 80, 20, G4P.SCROLLBARS_NONE);
  p_win_width.setText("1000");
  p_win_width.setPromptText("100");
  p_win_width.setOpaque(true);
  p_win_width.addEventHandler(this, "p_win_width_change1");
  p_win_width_label = new GLabel(this, 15, 150, 50, 20);
  p_win_width_label.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  p_win_width_label.setText(" Width");
  p_win_width_label.setOpaque(false);
  p_win_height_label = new GLabel(this, 15, 180, 50, 20);
  p_win_height_label.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  p_win_height_label.setText(" Height");
  p_win_height_label.setOpaque(false);
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
}

// Variable declarations 
// autogenerated do not edit
GButton run; 
GCheckbox test_mode; 
GCheckbox record; 
GLabel label1; 
GTextField p_win_height; 
GTextField p_win_width; 
GLabel p_win_width_label; 
GLabel p_win_height_label; 
GLabel ip_label; 
GLabel port_label; 
GLabel num_port_label; 
GTextField num_ports; 
GTextField port; 
GLabel ip; 

