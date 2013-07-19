#include <SPI.h>
#include <Ethernet.h>

// This Arduino's floor level
int level = 2;

// Room identifiers
char room_a = 'a';
char room_b = 'b';

// This Arduino's unique MAC
byte mac[] = { 0x90, 0xA2, 0xDA, 0x0E, 0x99, 0x09 };

// Door lock switch pins
int room_a_switch_pin = 8;
int room_b_switch_pin = 9;
 
// Wall indicator LED pins
int room_a_led_pin = 5;
int room_b_led_pin = 6;

// Last switch readings (potentially spurious, used for debouncing)
boolean room_a_last_reading = HIGH;
boolean room_b_last_reading = HIGH;

// Last switch readings after debouncing
int room_a_last_stable_reading = HIGH;
int room_b_last_stable_reading = HIGH;

// Debounce delays to filter out switch noise
// http://arduino.cc/en/Tutorial/Debounce
long debounce_delay = 50;
long room_a_last_debounce = 0;
long room_b_last_debounce = 0;

// Ethernet client
EthernetClient client;

long lastConnectionTime = 0; 
boolean lastConnected = false;
int failedCounter = 0;

// Server host to POST occupancy changes to
char serverHost[] = "gottago.medu.com";
char serverPath[] = "/api/event";
 
void setup()
{
  Serial.begin(9600);
  
  // Switch pins are inputs using the built-in pull-up resistors
  pinMode(room_a_switch_pin, INPUT_PULLUP);
  pinMode(room_b_switch_pin, INPUT_PULLUP);
  
  // LED pins are outputs
  pinMode(room_a_led_pin, OUTPUT);
  pinMode(room_b_led_pin, OUTPUT);
  
  // Light both LEDs until Ethernet is setup
  digitalWrite(room_a_led_pin, HIGH);
  digitalWrite(room_b_led_pin, HIGH);
  
  // Setup Ethernet connection
  startEthernet();
  delay(1000);
}
 
void loop()
{
  // Record inital room A input
  int room_a_reading = digitalRead(room_a_switch_pin);
  if (room_a_reading != room_a_last_reading)
  {
    room_a_last_debounce = millis();
  }
  
  // Record inital room B input
  int room_b_reading = digitalRead(room_b_switch_pin);
  if (room_b_reading != room_b_last_reading)
  {
    room_b_last_debounce = millis();
  }
  
  // Update the indicator lights
  digitalWrite(room_a_led_pin, !room_a_reading);
  digitalWrite(room_b_led_pin, !room_b_reading);
  
  // Debounce room A switch
  if ((millis() - room_a_last_debounce) > debounce_delay)
  {
    if (room_a_reading != room_a_last_stable_reading)
    {
      notify(level, room_a, (room_a_reading) ? false : true);
      room_a_last_stable_reading = room_a_reading;
    }
  }
  room_a_last_reading = room_a_reading;
  
  // Debounce room B switch
  if ((millis() - room_b_last_debounce) > debounce_delay)
  {
    if (room_b_reading != room_b_last_stable_reading)
    {
      notify(level, room_b, (room_b_reading) ? false : true);
      room_b_last_stable_reading = room_b_reading;
    }
  }
  room_b_last_reading = room_b_reading;
}

void startEthernet()
{
  client.stop();

  Serial.println("Waiting for DHCP...");
  Serial.println();  

  delay(1000);
  
  // Connect to network amd obtain an IP address using DHCP
  if (Ethernet.begin(mac) == 0)
  {
    Serial.println("DHCP Failed, reset Arduino to try again");
  }
  else
  {
    Serial.println("Arduino connected to network using DHCP");
  }
  
  delay(1000);
}

void notify(int level, char room, boolean occupied)
{
  if (client.connect(serverHost, 80))
  {
    String data = "floor=" + String(level, DEC) + "&room=" + String(room) + "&status=" + String(occupied, DEC);
    Serial.println("Making HTTP request: " + data);
    client.print("POST " + String(serverPath) + " HTTP/1.1\n");
    client.print("Host: " + String(serverHost) + "\n");
    client.print("Connection: close\n");
    client.print("Content-Type: application/x-www-form-urlencoded\n");
    client.print("Content-Length: ");
    client.print(data.length());
    client.print("\n\n");
    client.print(data);
    
    // Uncomment below to see HTTP responses
//    char c;
//    delay(1000);
//    while(client.connected() && !client.available()) delay(1); 
//    while (client.available()) {
//      c = client.read();
//      Serial.print(c);
//    }
//    client.stop();
//    client.flush();
    
    client.stop();
  }
}
