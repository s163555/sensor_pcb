#include <Adafruit_MAX31865.h>
#include <SPI.h>

#define LED_PIN     LED_BUILTIN
#define RREF        430.0
#define RNOMINAL    100.0
#define MAX31865_CS 10

Adafruit_MAX31865 thermo(MAX31865_CS);

void setup() {
  Serial.begin(115200);
  while (!Serial);

  pinMode(LED_PIN, OUTPUT);
  pinMode(MAX31865_CS, OUTPUT);
  digitalWrite(MAX31865_CS, HIGH);

  Serial.println("RTD Pt100 Test");

  thermo.begin(MAX31865_3WIRE);

  thermo.enableBias(true);
  delay(10);

  // For some reason the AFE needs to be primed before it can return valid data
  // Minimal SPI transaction below
  digitalWrite(MAX31865_CS, LOW);
  SPI.transfer(MAX31865_CONFIG_REG | 0x80); // read config register
  SPI.transfer(0x00);                       // dummy byte
  digitalWrite(MAX31865_CS, HIGH);

  delay(10); // allow conversion to settle
  thermo.enableBias(false);
}

void loop() {
  //uint16_t rtd = thermo.readRTD();
  float temperature = thermo.temperature(RNOMINAL, RREF);

  //Serial.print("RTD raw: "); Serial.print(rtd);
  //Serial.print(" | Temp: "); 
  Serial.println(temperature, 3);

  digitalWrite(LED_PIN, !digitalRead(LED_PIN));
  delay(1000);
}