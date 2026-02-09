Demo of Control Panel with 36 points
========================================
How to use:  testbenchLCD_task4_80frames.txt
--------------------------------------------
1/ Start FPGA-LCD Utils and open Testbench Viewer
2/ Load testbenchLCD_task4_80frames.txt from its menu File->Open 
3/ The frame record appears scrolled to its last frame
4/ Press rewind |<  button to got to the first frame or enter 1 into frame Up/Down control.
5/ Press play >

Note: The dynamic effects of the flashing Morse code element were disabled 
      during the testbench to speed up its run. Even so, it took 510 seconds to create 80 frames.
      But all 80 frames can be played back in 40 seconds. 

==============================================
How to use  ControlPanel_Demo.sof:
-----------------------------------------------
1/ Start Quartus.
2/ From the main Quartus menu, select Tools->Programmer.
3/ In Programmer, first perform the hardware setup for USB-Blaster. 
4/ Then, select only 1 *.sof (sof=SRAM Object File) by [Add File...].
5/ Downloaded it to the VEEK-MT2 board by [Start]. 

*** Controls *******************
--- LCD TOUCH SCREEN ---------------
* Touch the indicators of frequency or waiting time to change their value
* Touch play/stop mark to run/stop.

----IR REMOTE -----------
* Numbers: Enter the index of clock frequency.
* A B C Power - direct setting of the wait time
* Channel - frequency up/down
* Volume   - wait time up/down
* Play key - Play/Stop


