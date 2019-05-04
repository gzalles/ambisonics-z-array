%% clear

%this is the script I run each time I want to do a measurement to test that
%the arduino is properly connected. We are working on making the stepper
%system available for everyone, it will take some time though.

clc; clear;

%terminal command to find arduino
%ls /dev/tty.* 

%% connect

%the first argument will change depending on your computer, use terminal
%command shown above to find the port.
a = arduino('/dev/tty.usbmodem1411', 'Uno', 'Libraries', 'Adafruit\MotorShieldV2');

%% initialize

dev = addon(a, 'Adafruit\MotorShieldV2');
addrs = scanI2CBus(a, 0);
sprev = 100; %steps per revolution
motornum = 2;

%sm = stepper(dev, motornum, sprev, Name, Value)
%     dev      - Adafruit motor shield v2 object
%     motornum - Port number the motor is connected to on the shield (numeric)
%     sprev    - steps per revolution

sm = stepper(dev, motornum, sprev, 'stepType', 'Single');
sm.RPM = 10;%set revolutions per minute

%% step once

%use this to figure out how long it takes the booms to stabilize. 
timeBtwnSteps = 5; %time between steps

steps = 1;              %number of steps
%% single step test
move(sm, steps);        %move sm 1.8 degrees 

%%  the code below was used to find the "sweet spot"

% pause(timeBtwnSteps);   %pause to allow stabilization
% 
% %% do it again
% %dont use release, release used to spin freely, we don't want that.
% 
% move(sm, steps);
% pause(timeBtwnSteps);
% 
% %% do it one last time.
% move(sm, steps);
% pause(timeBtwnSteps);

%end of script

