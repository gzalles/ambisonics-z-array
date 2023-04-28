# Objective-C

I used ScanIR to get the impulse responses of my system. We also recycled the rotating mount project from our first paper to get polar measurements. This folder has functions and examples to calculate the DFR of the A-format signals and export the calibration filters.

I am eventually hoping to compare three methods of SMA encoding:

1. AF/BF calibration + static encoding matrix (using DFR for AF calibration and peak response for BF).
2. FM (filter matrix) encoding using ideal SHs to solve the system of linear equations.
3. Static encoding matrix plus radial filters. 

One could also combine these methods to try to find an optimal subjective solution. I am also conducting subjective evals via prolific.com
