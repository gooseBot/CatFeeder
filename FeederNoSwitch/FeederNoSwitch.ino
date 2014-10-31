#include <NewSoftSerial.h>
#include <AFMotor.h>

const int DOORSENSOR_CLOSED=10;
const int DOORSENSOR_OPEN=9;
const int IR_pin = 3;   
const int IR_cutoff=200;
const int OPEN=1;
const int CLOSE=0;
const int set_time1=15000;

int printed_already;
int door_state;
int IR_Read_value;
long startMillis;

//int val;
//int incomingByte = 0; 

AF_DCMotor motor(4, MOTOR12_64KHZ); 
NewSoftSerial mySerial(2, 3);

void setup() {
  Serial.begin(9600);           
  mySerial.begin(9600);
  Serial.println("Cat feeder!");
  motor.setSpeed(185);
  pinMode(DOORSENSOR_OPEN, INPUT);
  pinMode(DOORSENSOR_CLOSED, INPUT);
  door_state=CLOSE;
  printed_already=0;
}

void loop() {
  byte valr;
  if((RFID() == 1) && (door_state==CLOSE))//RF activated
    {
    MoveDoor(OPEN);
    }
  else //RF not active, we may have to close the door
    {
    if(door_state==OPEN)//DOOR is open
      {
      if(analogRead(IR_pin)<IR_cutoff)//there is no cat
        {
        startMillis = millis();
        Serial.println("starting timer...");
        //while nothing happens, the timer runs out
        while(millis()-startMillis<set_time1) 
          {
          IR_Read_value = analogRead(IR_pin);
          //if(millis()%500<5)
          Serial.println(IR_Read_value); 
          //Serial.println(IR_cutoff); 
          if(IR_Read_value>=IR_cutoff)
            {
            Serial.println("Cat detected. Resetting timer ...");
            delay(1000);
            startMillis = millis();
            }
          }  
          
          Serial.println("Timer ran out.");  
          while(mySerial.available())
            valr = mySerial.read();//empty the buffer
          MoveDoor(CLOSE); //close the door          
        }
      }  
    } 
}  
    
    
void MoveDoor(int openclose)
    {
    int cat_alert;
    cat_alert=0;  
    if(openclose==CLOSE) //close the door!
      {
      motor.run(BACKWARD);   
      while ((digitalRead(DOORSENSOR_CLOSED)==LOW) && cat_alert==0)
        {
        if(analogRead(IR_pin)>IR_cutoff)
          {
          delay(20);
          if(analogRead(IR_pin)>IR_cutoff)
            {
            cat_alert=1;  
            motor.run(RELEASE);
            openclose=OPEN;
            }
          }
        }  
      
       //if there is no cat
       //if there is, door opens in next if-statement
        if(cat_alert==0)
          {
          motor.run(RELEASE);
          door_state=CLOSE;
          Serial.println("it's closed.");
          }
      }
    
    if(openclose==OPEN) //open the door!
      { 
      motor.run(FORWARD); 
      Serial.println("opening.");
      while ((digitalRead(DOORSENSOR_OPEN)==LOW) ); 
      motor.run(RELEASE); 
      door_state=OPEN;
      Serial.println("it's open.");
      }
}    
    
    
int RFID() 
  {
  byte i = 0;
  byte val = 0;
  byte code[6];
  byte checksum = 0;
  byte bytesread = 0;
  byte tempbyte = 0;
  int result = 0;

  if(mySerial.available()) {
    result=1;
    if((val = mySerial.read()) == 0x02) { 
      bytesread = 0; 
      Serial.println("I read it");
      while (bytesread < 12) {// read 10 digit code + 2 digit checksum
        if(mySerial.available()) { 
          val = mySerial.read();
          if((val == 0x0D)||(val == 0x0A)||(val == 0x03)||(val == 0x02)) {  
            break; // stop reading
          }

          // Do Ascii/Hex conversion:
          if ((val >= '0') && (val <= '9')) {
            val = val - '0';
          } else if ((val >= 'A') && (val <= 'F')) {
            val = 10 + val - 'A';
          }

          // Every two hex-digits, add byte to code:
          if (bytesread & 1 == 1) {
            // make some space for this hex-digit by
            // shifting the previous hex-digit with 4 bits to the left:
            code[bytesread >> 1] = (val | (tempbyte << 4));

            if (bytesread >> 1 != 5) {// If we're at the checksum byte,
              checksum ^= code[bytesread >> 1];// Calculate the checksum... (XOR)
            };
          } else {
            tempbyte = val; // Store the first hex digit first...
          };
          bytesread++; // ready to read next digit
        } 
      } 

      // Output to Serial:

      if (bytesread == 12) {  // if 12 digit read is complete
        Serial.print("5-byte code: ");
        for (i=0; i<5; i++) {
          if (code[i] < 16) mySerial.print("0");
          Serial.print(code[i], HEX);
          Serial.print(" ");
        }
        Serial.println();
        Serial.print("Checksum: ");
        Serial.print(code[5], HEX);
        Serial.println(code[5] == checksum ? " -- passed." : " -- error.");
        if(code[5] == checksum)
        result=1;
        Serial.println();
      }
      bytesread = 0;
    }
  }
  return result;
}


