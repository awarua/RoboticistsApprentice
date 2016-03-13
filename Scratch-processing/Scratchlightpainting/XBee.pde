class XBee {
  byte seqno;
  Serial serial;
  
  XBee(int xbeePort, int baudRate, PApplet sketch) {
    // Set up serial object for xbee communication.
    // use 'printArray(Serial.list())' to find xbee port number.
    serial = new Serial(sketch, Serial.list()[xbeePort], baudRate);
    printArray(Serial.list());
  }

  // Transmits the message to the cube. Need to add a new seqno and recalculate the crc.
  void relayMsg(byte[] msg) {
    seqno++;
    msg[msg.length - 2] = seqno;
    byte crc = generateCrc(msg);
    msg[msg.length - 1] = crc;
    serial.write(msg);
  }
  
  void still(byte[] msg) {
    msg[4] = 100;
    msg[5] = 100; 
    relayMsg(msg);
  }
  
  void turnright(byte[] msg){
    msg[4] = 98;
    msg[5] = 102;
    relayMsg(msg);
  }
  
  void turnleft(byte[] msg){
    msg[4] = 102;
    msg[5] = 98;
    relayMsg(msg);
  }
  
  void forward(byte[] msg){
    msg[4] = 92;
    msg[5] = 92;
    relayMsg(msg);
  }
  
  void backward(byte[] msg){
    msg[4] = 115;
    msg[5] = 115;
    relayMsg(msg);
  }
 
   void lightson(byte[] msg){
      msg[0] = byte(170);
      msg[1] = byte(85);
      msg [3] = byte(120); 
      
      msg[5] = byte(0);//nothing
      msg[6] = byte(100);//brightness
      msg[7] = byte(1);//fadeTime
      msg[8] = byte(seqno);
      msg[9] = byte(0);
      relayMsg(msg);
      //reset back to mode for movement
      msg[0] = -86; 
      msg[1] = 85;  
      msg[2] = -6;  
      msg[3] = 1;  
      msg[4] = 100; 
      msg[5] = 100;  
      msg[6] = 3;  
      msg[7] = 0; 
    }
    
    void lightsoff(byte[] msg){
      msg[0] = byte(170);
      msg[1] = byte(85);
      msg [3] = byte(120);
      msg[5] = byte(0);
      msg[6] = byte(0);
      msg[7] = byte(1);
      msg[8] = byte(seqno);
      msg[9] = byte(0);
      relayMsg(msg);
      //reset back to mode for movement
      msg[0] = -86; 
      msg[1] = 85;  
      msg[2] = -6;  
      msg[3] = 1;  
      msg[4] = 100; 
      msg[5] = 100;  
      msg[6] = 3;  
      msg[7] = 0;  
    }
  byte generateCrc(byte[] msg) {

    // Calculate a new crc for the message. This will be included as the last byte.
    byte crc = 0;
    for (int i = 0; i < msg.length - 1; i++) {
      crc ^= msg[i];
    }

    return crc;
  }
}