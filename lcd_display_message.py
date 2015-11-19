#!/usr/bin/python

# Python display control for the 16x2 LCD display
# m. kling | 2015-11-18

# Takes 2 command-line parameters: message and color

import sys
import time
import Adafruit_CharLCD as LCD

lcd = LCD.Adafruit_CharLCDPlate()

lcd.clear()

color = str(sys.argv[2])

if color == 'red':
    lcd.set_color(1,0,0)
elif color == "green":
    lcd.set_color(0,1,0)
elif color == "blue":
    lcd.set_color(0,0,1)
elif color == "yellow":
    lcd.set_color(1,1,0)
elif color == "magneta":
    lcd.set_color(1,0,1)    
elif color == "cyan":
    lcd.set_color(0,1,1)
elif color == "white":
    lcd.set_color(1,1,1)
elif color == "off":
    lcd.set_color(0,0,0)
else:
    lcd.set_color(0,0,1)
    
lcd.message(sys.argv[1])

# time.sleep(5)
