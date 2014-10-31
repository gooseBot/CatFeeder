

const int DOORSENSOR_OPEN=9;
const int DOORSENSOR_CLOSED=10;

void setup() {
  Serial.begin(9600);      
  Serial.println("Motor test!");
  
  pinMode(DOORSENSOR_OPEN, INPUT);
  pinMode(DOORSENSOR_CLOSED, INPUT);
}

void loop() {
  Serial.println(digitalRead(9));
}
