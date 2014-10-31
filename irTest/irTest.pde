const int IR_pin=3;//analog

int IR_STATE;
int val;
void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("IR test!");
  IR_STATE=0;
  pinMode(IR_pin,INPUT);
}

void loop() {
  val = analogRead(IR_pin);    // read the value from the sensor
  Serial.println(val);
  delay(100);
}

