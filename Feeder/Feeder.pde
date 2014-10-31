#include <NewSoftSerial.h>
#include <AFMotor.h>
const int DOORSENSOR_CLOSED=A0;
const int DOORSENSOR_OPEN=A1;
const int MODE_pin=A2;
const int MANUALOPEN_pin=A3;
const int IR_pin = 4;   
const int IR_cutoff=175;
int printed_already;

//RF reader is connected to RX pin 0 for serial input

const int OPEN=1;
const int CLOSE=0;
int door_state;
int val; 

const int set_time1=15000;
long startMillis;
AF_DCMotor motor(3, MOTOR12_64KHZ); 
NewSoftSerial mySerial(0, 1);

int incomingByte = 0; 

void setup() {
  Serial.begin(9600);           
  mySerial.begin(9600);
  Serial.println("Cat feeder!");
  motor.setSpeed(200);
 pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  digitalWrite(A0,HIGH);
  digitalWrite(A1,HIGH);
  digitalWrite(A2,HIGH);
  digitalWrite(A3,HIGH);
  door_state=CLOSE;
  printed_already=0;
}

void loop() {
  byte valr;
  if(digitalRead(MODE_pin)==LOW) //switch set to manual
  {
    delay(10);
    if(digitalRead(MODE_pin)==LOW)//debouncing
    {
     if((printed_already==0) || (printed_already==2))
     {
     Serial.println("MODE = manual");
     printed_already=1;
     }
      if(digitalRead(MANUALOPEN_pin)==LOW) //toggle button is pressed
      {
        delay(10);
        if(digitalRead(MANUALOPEN_pin)==LOW)//debouncing
        {  
          if(door_state==OPEN)  
          {
            Serial.println("trying to close now ...");
            MoveDoor(CLOSE);//close the door
          }
          else if(door_state==CLOSE)  
          {
            Serial.println("trying to open now ...");
            MoveDoor(OPEN);//close the door
          }          
        }
      }
    }
  }
  else if(digitalRead(MODE_pin)==HIGH) //switch set to automatic
  {  
  delay(10);
  if(digitalRead(MODE_pin)==HIGH) //debouncing
    {
    if((printed_already==0) | (printed_already==1))
     {
      Serial.println("MODE = automatic");
      printed_already=2;
     }  
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
            //if(millis()%500<5)
            Serial.println(analogRead(IR_pin)); 
            //Serial.println(IR_cutoff); 
            if(analogRead(IR_pin)>=IR_cutoff)
              {
              Serial.println("Cat detected. Resetting timer ...");
              delay(1000);
              startMillis = millis();
              }
            }  
        
          if(analogRead(IR_pin)<IR_cutoff) 
          //RF is still not activated, there really is no cat
            {
            Serial.println("Timer ran out.");  
              while(mySerial.available())
              valr = mySerial.read();//empty the buffer
            MoveDoor(CLOSE); //close the door
            }
          }
        }  
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
      motor.run(FORWARD);   
      while ( (digitalRead(DOORSENSOR_OPEN)==HIGH) && cat_alert==0)
         {if(analogRead(IR_pin)>IR_cutoff)
           {delay(20);
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
      motor.run(BACKWARD); 
      while ((digitalRead(DOORSENSOR_CLOSED)==HIGH) ); 
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


