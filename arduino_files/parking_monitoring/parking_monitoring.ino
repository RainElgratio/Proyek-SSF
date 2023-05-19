//----------------------------------------------
// Assembly via Arduino - I2C Master Transmitter
//----------------------------------------------
extern "C"
{
  void I2C_master();
  void lcd_write_string();
}
//----------------------------------------------
void setup()
{
  I2C_master();
}
//----------------------------------------------
void loop()
{
  lcd_write_string();
}