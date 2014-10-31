#include <AFMotor.h>


const int DOORSENSOR_OPEN=A1;
const int DOORSENSOR_CLOSED=A0;
AF_DCMotor motor(3, MOTOR12_64KHZ); 

void setup() {
  Serial.begin(9600);      
  Serial.println("Motor test!");
  motor.setSpeed(200);    
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  digitalWrite(A0,HIGH);
  digitalWrite(A1,HIGH);
}

void loop() {
  Serial.println("trying to open");
  while ((digitalRead(DOORSENSOR_OPEN)==HIGH)  )
    { 
    Serial.println("not open yet");  
    motor.run(FORWARD);     
    }
  Serial.println("it is open");
  motor.run(RELEASE);    
  delay(1000);
  
  Serial.println("trying to close");
  while ((digitalRead(DOORSENSOR_CLOSED)==HIGH)  )
    {
    Serial.println("not closed yet"); 
    motor.run(BACKWARD);     
    }  
  Serial.println("it is closed");
  motor.run(RELEASE);    
  delay(1000);
}


