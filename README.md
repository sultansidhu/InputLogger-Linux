# InputLogger-Linux
A C++ implementation of an input logger, accesses the low-level raw data sent by input devices (keyboard and mouse) and records it in a log file.

## Before use: 
- Run the following command: <b>ls -l /dev/input/by-{input,id}</b>
- Locate the event file that controls the event mouse connected with the device
- Change the event file name within the keylogger.cpp, within the main function

## During use: 
- Compile the program using the g++ compiler with the command: <b>g++ -o keylogger keylogger.cpp -lX11</b>
- Make sure to include the <b>-lX11</b> flag, which links the executible to X11, and thus enables many of the low-level functions used by this program
- Run the executible using the <b>sudo</b> keyword: <b>sudo ./keylogger output.log</b> with output.log being the output log file

## General information: 
- The coordinates displayed by the function correspond to the origin being at the top left corner of the screen
- The absence of <b>sudo</b> in the command would lead to permissions being denied to access the event files within the Linux Event Subsystem
- Access to the output within the log file also requires the <b>sudo</b> keyword
