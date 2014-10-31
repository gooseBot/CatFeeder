#include <AFMotor.h>

const int DOORSENSOR_CLOSED=A0;
const int DOORSENSOR_OPEN=A1;
const int MANUALMODE_pin=A2;
const int MANUALOPEN_pin=A3;
const int OPEN=1;
const int CLOSE=0;
int toggle_state;
int printed_already;

AF_DCMotor motor(3, MOTOR12_64KHZ);

void setup() {
  Serial.begin(9600);          
  Serial.println("Motor test!");
  motor.setSpeed(200);    
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  digitalWrite(A0,HIGH);
  digitalWrite(A1,HIGH);
  digitalWrite(A2,HIGH);
  digitalWrite(A3,HIGH);
  toggle_state=CLOSE;
  printed_already=0;
}

void loop() {
  
  if(digitalRead(MANUALMODE_pin)==LOW) //switch set to manual
  {
    delay(10);
    if(digitalRead(MANUALMODE_pin)==LOW)//debouncing, switch really set to manual
    {
     if((printed_already==0) || (printed_already==2))
     {
     Serial.println("MODE = manual");
     printed_already=1;
     }
      if(digitalRead(MANUALOPEN_pin)==LOW) //toggle button is pressed
      {
        delay(10);
        if(digitalRead(MANUALOPEN_pin)==LOW)//debouncing, toggle button is really pressed
        {  
         Serial.println("button pressed");
          if(toggle_state==OPEN)  
          {
            Serial.println("trying to close now ...");
            toggle_state=MoveTray(CLOSE);
          }
          else if(toggle_state==CLOSE)  
          {
            Serial.println("trying to open now ...");
            toggle_state=MoveTray(OPEN);
          }          
        }
      }
    }
  }
  else if(digitalRead(MANUALMODE_pin)==HIGH) //switch is set to automatic
  {  
    delay(10);
    if(digitalRead(MANUALMODE_pin)==HIGH) //debouncing, switch really set to automatic
    {
     if((printed_already==0) | (printed_already==1))
     {
      Serial.println("MODE = automatic");
      printed_already=2;
     }

      motor.run(FORWARD);
      while ((digitalRead(DOORSENSOR_OPEN)==HIGH));
      motor.run(RELEASE);
      delay(1000);
     

      motor.run(BACKWARD);
      while ((digitalRead(DOORSENSOR_CLOSED)==HIGH)); 
      motor.run(RELEASE);
      delay(1000);
    }
  }
}

int MoveTray(int openclose)
    {
    if(openclose==OPEN) //open the door!
      {
        motor.run(BACKWARD);    
        while ((digitalRead(DOORSENSOR_CLOSED)==HIGH)); 
        toggle_state=OPEN; 
        motor.run(RELEASE);
        Serial.println("it's open.");
      }
   
    if(openclose==CLOSE) //close the door!
      {
        motor.run(FORWARD);     
        while ((digitalRead(DOORSENSOR_OPEN)==HIGH) );
        toggle_state=CLOSE; 
        motor.run(RELEASE); 
        Serial.println("it's closed.");
      }
      return toggle_state;
    }


