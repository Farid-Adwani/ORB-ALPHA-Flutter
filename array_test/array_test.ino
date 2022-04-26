/* 
 * rosserial::geometry_msgs::PoseArray Test
 * Sums an array, publishes sum 
 */

#include <ros.h>
#include <geometry_msgs/Inertia.h>
#include <std_msgs/Int32.h>
#include <SharpIR.h> 
#include <Wire.h>
#include <Servo.h>
const int MPU = 0x68; // MPU6050 I2C address
float AccX, AccY, AccZ;
float GyroX, GyroY, GyroZ;
float accAngleX, accAngleY, gyroAngleX, gyroAngleY, gyroAngleZ;
float roll, pitch, yaw;
float AccErrorX, AccErrorY, GyroErrorX, GyroErrorY, GyroErrorZ;
float elapsedTime, currentTime, previousTime;
int c = 0;
Servo servo1 ;
Servo servo2 ;
Servo servo3 ;


#define sharp1Pin A0
#define sharp2Pin A1

#define mr1 6
#define mr2 11
#define ml1 5
#define ml2 3


void forward(int vit){
  analogWrite(mr1,vit);
  analogWrite(mr2,0);
  analogWrite(ml1,vit);
  analogWrite(ml2,0);
}

void backward(int vit){
  analogWrite(mr1,0);
  analogWrite(mr2,vit);
  analogWrite(ml1,0);
  analogWrite(ml2,vit);
}
void right(int vit){
  analogWrite(mr1,0);
  analogWrite(mr2,vit);
  analogWrite(ml1,vit);
  analogWrite(ml2,0);
}
void left(int vit){
  analogWrite(mr1,vit);
  analogWrite(mr2,0);
  analogWrite(ml1,0);
  analogWrite(ml2,vit);
}
void Stop(){
  analogWrite(mr1,0);
  analogWrite(mr2,0);
  analogWrite(ml1,0);
  analogWrite(ml2,0);
}
ros::NodeHandle nh;


#define ir1 12
#define ir2 4
#define ir3 2

void orderCallback( const std_msgs::Int32& order){
  if(order.data==1){
    forward(180);
    delay(500);
    Stop();
  }else if(order.data==2){
    backward(180);
    delay(500);
    Stop();
  }else if(order.data==3){
    right(180);
    delay(500);
    Stop();
  }
  else if(order.data==4){
    left(180);
    delay(500);
    Stop();
  }
  else {
    forward(100);
    delay(500);
    Stop();
  }
}
ros::Subscriber<std_msgs::Int32> orderSub("order", &orderCallback);

geometry_msgs::Inertia sensors;
ros::Publisher p("/sensors", &sensors);

void gyroInit(){

 Serial.begin(115200);
  Wire.begin();                      // Initialize comunication
  Wire.beginTransmission(MPU);       // Start communication with MPU6050 // MPU=0x68
  Wire.write(0x6B);                  // Talk to the register 6B
  Wire.write(0x00);                  // Make reset - place a 0 into the 6B register
  Wire.endTransmission(true);        //end the transmission
  calculate_IMU_error();
  delay(20);
  }


void setup()
{ 
  pinMode(ir1,INPUT);
  pinMode(ir2,INPUT);
  pinMode(ir3,INPUT);
  pinMode(13, INPUT);
  pinMode(sharp1Pin, INPUT);
  pinMode(sharp2Pin, INPUT);
  pinMode(mr1,OUTPUT);
  pinMode(mr2,OUTPUT);
  pinMode(ml1,OUTPUT);
  pinMode(ml2,OUTPUT);
  servo1.attach(9);
  servo2.attach(8);
  servo3.attach(7);
  
  Serial.begin(115200);
Serial.println("bdinzaz");

  nh.initNode();
  nh.advertise(p);
  nh.subscribe(orderSub);
    gyroInit();


  
}
void readGyro(){
  // === Read acceleromter data === //
  Wire.beginTransmission(MPU);
  Wire.write(0x3B); // Start with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 6, true); // Read 6 registers total, each axis value is stored in 2 registers
  //For a range of +-2g, we need to divide the raw values by 16384, according to the datasheet
  AccX = (Wire.read() << 8 | Wire.read()) / 16384.0; // X-axis value
  AccY = (Wire.read() << 8 | Wire.read()) / 16384.0; // Y-axis value
  AccZ = (Wire.read() << 8 | Wire.read()) / 16384.0; // Z-axis value
  // Calculating Roll and Pitch from the accelerometer data
  accAngleX = (atan(AccY / sqrt(pow(AccX, 2) + pow(AccZ, 2))) * 180 / PI) - 0.58; // AccErrorX ~(0.58) See the calculate_IMU_error()custom function for more details
  accAngleY = (atan(-1 * AccX / sqrt(pow(AccY, 2) + pow(AccZ, 2))) * 180 / PI) + 1.58; // AccErrorY ~(-1.58)
  // === Read gyroscope data === //
  previousTime = currentTime;        // Previous time is stored before the actual time read
  currentTime = millis();            // Current time actual time read
  elapsedTime = (currentTime - previousTime) / 1000; // Divide by 1000 to get seconds
  Wire.beginTransmission(MPU);
  Wire.write(0x43); // Gyro data first register address 0x43
  Wire.endTransmission(false);
  Wire.requestFrom(MPU, 6, true); // Read 4 registers total, each axis value is stored in 2 registers
  GyroX = (Wire.read() << 8 | Wire.read()) / 131.0; // For a 250deg/s range we have to divide first the raw value by 131.0, according to the datasheet
  GyroY = (Wire.read() << 8 | Wire.read()) / 131.0;
  GyroZ = (Wire.read() << 8 | Wire.read()) / 131.0;
  // Correct the outputs with the calculated error values
  GyroX = GyroX + 0.56; // GyroErrorX ~(-0.56)
  GyroY = GyroY - 2; // GyroErrorY ~(2)
  GyroZ = GyroZ + 0.79; // GyroErrorZ ~ (-0.8)
  // Currently the raw values are in degrees per seconds, deg/s, so we need to multiply by sendonds (s) to get the angle in degrees
  gyroAngleX = gyroAngleX + GyroX * elapsedTime; // deg/s * s = deg
  gyroAngleY = gyroAngleY + GyroY * elapsedTime;
  yaw =  yaw + GyroZ * elapsedTime;
  // Complementary filter - combine acceleromter and gyro angle values
  roll = 0.96 * gyroAngleX + 0.04 * accAngleX;
  pitch = 0.96 * gyroAngleY + 0.04 * accAngleY;
  
  }

  void handleFall(float dis1,float dis2){
    if(dis1>12){
      backward(255);
    }/*else if(dis2>15){
      forward(200);
    }*/
    else{
      Stop();
    }
  }
void loop()
{  
  readGyro();
  float volts1 = analogRead(sharp1Pin)*0.0048828125;  
 float  dist1 = 13*pow(volts1, -1); 

   float volts2 = analogRead(sharp2Pin)*0.0048828125;  
 float  dist2 = 13*pow(volts2, -1);
 
  sensors.ixx=digitalRead(ir1);
  sensors.ixy=digitalRead(ir2);
  sensors.ixz=digitalRead(ir3);
  sensors.iyy=dist1;
  sensors.iyz=dist2;
  sensors.izz=99999;
  sensors.com.x=roll;
  sensors.com.y=pitch;
  sensors.com.z=yaw;
  Serial.print(sensors.ixx);
  Serial.print("    ");
  Serial.print(sensors.ixz);
  Serial.print("    ");
  Serial.print(sensors.ixy);
  Serial.print("    ");
  Serial.print(dist1);
  Serial.print("    ");
  Serial.println(dist2);
  handleFall(dist1,dist2);
  p.publish(&sensors);
  nh.spinOnce();
  
  delay(1);
}

void calculate_IMU_error() {
  // We can call this funtion in the setup section to calculate the accelerometer and gyro data error. From here we will get the error values used in the above equations printed on the Serial Monitor.
  // Note that we should place the IMU flat in order to get the proper values, so that we then can the correct values
  // Read accelerometer values 200 times
  while (c < 200) {
    Wire.beginTransmission(MPU);
    Wire.write(0x3B);
    Wire.endTransmission(false);
    Wire.requestFrom(MPU, 6, true);
    AccX = (Wire.read() << 8 | Wire.read()) / 16384.0 ;
    AccY = (Wire.read() << 8 | Wire.read()) / 16384.0 ;
    AccZ = (Wire.read() << 8 | Wire.read()) / 16384.0 ;
    // Sum all readings
    AccErrorX = AccErrorX + ((atan((AccY) / sqrt(pow((AccX), 2) + pow((AccZ), 2))) * 180 / PI));
    AccErrorY = AccErrorY + ((atan(-1 * (AccX) / sqrt(pow((AccY), 2) + pow((AccZ), 2))) * 180 / PI));
    c++;
  }
  //Divide the sum by 200 to get the error value
  AccErrorX = AccErrorX / 200;
  AccErrorY = AccErrorY / 200;
  c = 0;
  // Read gyro values 200 times
  while (c < 200) {
    Wire.beginTransmission(MPU);
    Wire.write(0x43);
    Wire.endTransmission(false);
    Wire.requestFrom(MPU, 6, true);
    GyroX = Wire.read() << 8 | Wire.read();
    GyroY = Wire.read() << 8 | Wire.read();
    GyroZ = Wire.read() << 8 | Wire.read();
    // Sum all readings
    GyroErrorX = GyroErrorX + (GyroX / 131.0);
    GyroErrorY = GyroErrorY + (GyroY / 131.0);
    GyroErrorZ = GyroErrorZ + (GyroZ / 131.0);
    c++;
  }
  //Divide the sum by 200 to get the error value
  GyroErrorX = GyroErrorX / 200;
  GyroErrorY = GyroErrorY / 200;
  GyroErrorZ = GyroErrorZ / 200;

}
