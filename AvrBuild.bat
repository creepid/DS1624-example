@ECHO OFF
"D:\AVRS4\AvrAssembler2\avrasm2.exe" -S "D:\myAVR\ds1624\labels.tmp" -fI -W+ie -C V2E -o "D:\myAVR\ds1624\ds1624.hex" -d "D:\myAVR\ds1624\ds1624.obj" -e "D:\myAVR\ds1624\ds1624.eep" -m "D:\myAVR\ds1624\ds1624.map" "D:\myAVR\ds1624\ds1624.asm"
