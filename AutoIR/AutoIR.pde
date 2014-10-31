#include <AFMotor.h>

const int DOORSENSOR_CLOSED=A0;
const int DOORSENSOR_OPEN=A1;
const int MANUALMODE_pin=A2;
const int MANUALOPEN_pin=A3;
const int IR_pin = 4;    // analog input pin for the IR sensor
const int OPEN=1;
const int CLOSE=0;
int door_state;
int val;       // variable to store the value coming from the IR sensor

//IR emitter is always on (5V)


AF_DCMotor motor(3, MOTOR12_64KHZ); // create motor #2, 64KHz pwm

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Motor test!");
  motor.setSpeed(200);     // set the speed to 200/255
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
}

void loop() {
  
  if(digitalRead(MANUALMODE_pin)==LOW) //switch set to manual
  {
    delay(10);
    if(digitalRead(MANUALMODE_pin)==LOW)//debouncing, switch really set to manual
    {
      if(digitalRead(MANUALOPEN_pin)==LOW) //toggle button is pressed
      {
        delay(10);
        if(digitalRead(MANUALOPEN_pin)==LOW)//debouncing, toggle button is really pressed
        {  
          if(door_state==OPEN)  
          {
            Serial.println("trying to close now ...");
            MoveTray(CLOSE);//close the door
          }
          else if(door_state==CLOSE)  
          {
            Serial.println("trying to open now ...");
            MoveTray(OPEN);//close the door
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
      if(door_state==OPEN)  
      {
      Serial.println("trying to close now ...");
      MoveTray(CLOSE);//close the door
      }
      else if(door_state==CLOSE)  
      {
      Serial.println("trying to open now ...");
      MoveTray(OPEN);//close the door
      }      
      delay(1000);
    }
  }
}   


void MoveTray(int openclose)
    {
    int cat_alert;
    cat_alert=0;  
    if(openclose==CLOSE) //close the door!
    {
      motor.run(FORWARD);      
      while ((digitalRead(DOORSENSOR_OPEN)==HIGH) && cat_alert==0)
      {
        if(analogRead(IR_pin)>80)
        {
          delay(20);
          if(analogRead(IR_pin)>80)
          {
            cat_alert=1;  
            motor.run(RELEASE);
            openclose=OPEN;
          }
        }
      }  
      
    //while the door is not entirely closed and there is no cat
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
      while ((digitalRead(DOORSENSOR_CLOSED)==HIGH) ); //while the door is not entirely open 
      motor.run(RELEASE); 
      door_state=OPEN;
      Serial.println("it's open.");
    }
}





