#include <SPI.h>
#include <Ethernet.h>
#include "sha256.h"


// Local Network Settings
byte mac[] = { 0x90, 0xA2, 0xDA, 0x0E, 0x99, 0x09 }; // Must be unique on local network


// Variable Setup
long lastConnectionTime = 0; 
boolean lastConnected = false;
int failedCounter = 0;

// Initialize Arduino Ethernet Client
EthernetClient client;


// ThingSpeak Settings
char thingSpeakAddress[] = "api.thingspeak.com";
String bathroomPostAPIKey = "7568KTGD1GFQN1DF";
//String bathroomPostAPIKey = "OUW598TV1ONCNK8A8";
 
bathroom = {
  avail: 0,
  locked: 1
}


int bathroomALed = 12;
int bathroomBLed = 13;

int sensorA = A0;
int sensorB = A1;


void setup() {
  // initialize serial communication:
  Serial.begin(9600);  
  
  pinMode(bathroomALed, OUTPUT);   
  pinMode(bathroomBLed, OUTPUT);   

  
   // Start Ethernet on Arduino
  startEthernet();
  
  delay(1000);
  
}

void loop() {
  // read the sensor:
  int sensorA_Reading = analogRead(sensorA);
  if(sensorA_Reading > 0){
    Serial.println("A Open");
    digitalWrite(bathroomALed, LOW);    // turn the LED off by making the voltage LOW
    updateBathroomStatus({
      GGFloor: 2,
      GGRoom: "a",
      GGStatus: bathroom.locked
    });
  }else  {
    Serial.println("A Lock");
    digitalWrite(bathroomALed, HIGH);   // turn the LED on (HIGH is the voltage level)
    updateBathroomStatus({
      GGFloor: 2,
      GGRoom: "a",
      GGStatus: bathroom.avail
    });
  }
  
  int sensorB_Reading = analogRead(sensorB);
      Serial.println(sensorB_Reading);

  if(sensorB_Reading > 0){
    Serial.println("B Open");
    digitalWrite(bathroomBLed, LOW);    // turn the LED off by making the voltage LOW
    updateBathroomStatus({
      GGFloor: 2,
      GGRoom: "b",
      GGStatus: bathroom.locked
    });
  }else  {
    Serial.println("B Lock");
    digitalWrite(bathroomBLed, HIGH);   // turn the LED on (HIGH is the voltage level)
    updateBathroomStatus({
      GGFloor: 2,
      GGRoom: "b",
      GGStatus: bathroom.avail
    });
  }
  
  
  
    
  // Print Update Response to Serial Monitor
  if (client.available())
  {
    char c = client.read();
    Serial.print(c);
  }
  
  // Disconnect from ThingSpeak
  if (!client.connected() && lastConnected)
  {
    Serial.println("...disconnected");
    Serial.println();
    
    client.stop();
  }
    
  // Check if Arduino Ethernet needs to be restarted
  if (failedCounter > 3 ) {startEthernet();}
  
  lastConnected = client.connected();
  
  
  
  delay(1);        // delay in between reads for stability
}



void updateBathroomStatus( bathroomObj ) {
  if (client.connect(thingSpeakAddress, 80))
  { 
    // Create HTTP POST Data
    var data = "api_key="+bathroomPostAPIKey+"&floor="+bathroomObj.GGFloor+"&room="+bathroomObj.GGRoom+"&status="+bathroomObj.GGStatus;
    uint8_t hmacKey={
  0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c
};

    Sha256.initHmac(hmacKey4,20);
    Sha256.print(data);

    var hash = Sha256.resultHmac()
    
    // /apps/thinghttp/send_request?api_key=7568KTGD1GFQN1DF
    client.print("POST /apps/thinghttp/send_request HTTP/1.1\n");
    client.print("Host: api.thingspeak.com\n");
    client.print("Connection: close\n");
    client.print("Content-Type: application/x-www-form-urlencoded\n");
    client.print("Content-Length: ");
    client.print(hash.length());
    client.print("\n\n");

    client.print(hash);
    
    lastConnectionTime = millis();
    
    if (client.connected())
    {
      Serial.println("Connecting to ThingSpeak...");
      Serial.println();
      
      failedCounter = 0;
    }
    else
    {
      failedCounter++;
  
      Serial.println("Connection to ThingSpeak failed ("+String(failedCounter, DEC)+")");   
      Serial.println();
    }
    
  }
  else
  {
    failedCounter++;
    
    Serial.println("Connection to ThingSpeak Failed ("+String(failedCounter, DEC)+")");   
    Serial.println();
    
    lastConnectionTime = millis(); 
  }
}

void startEthernet() {
  
  client.stop();

  Serial.println("Connecting Arduino to network...");
  Serial.println();  

  delay(1000);
  
  // Connect to network amd obtain an IP address using DHCP
  if (Ethernet.begin(mac) == 0)
  {
    Serial.println("DHCP Failed, reset Arduino to try again");
    Serial.println();
  }
  else
  {
    Serial.println("Arduino connected to network using DHCP");
    Serial.println();
  }
  
  delay(1000);
}
