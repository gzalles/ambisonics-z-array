# MEMS FOA Mic

## About
This is a first order ambisonic microphone that uses MEMS {analog} capsules (ICS-40720). This repository contains instructions to make your own system as well as code to help you process your recordings, encode the data, and will in the future contain a more sophisticated version of this project which allows for USB connectivity. The repo also has 3D models which you can print.

## Why

Ambisonic hardware is extremely expensive and hard to come by. MEMS capsules are cool because they have great part-to-part consistency. Over the years their SNR and frequency response have improved drastically. With a little bit of processing before encoding we can get a decent ambisonic recording that's made from parts costing around $50. The size of these capsules also make it possible to theoretically achieve distortion free pressure gradients well above 20kHz.

## What

1. CAD models
2. Gerber files
3. Matlab functions
4.

## Materials
1. 30 gauge AWG wire
  * Used to connect multiple PCBs with MEMS to BOB (Breakout Board) via pin housing. BOB used to supply 3V to MEMS in lieu of complicated step-down circuit relying on phantom power (48V).
  * I used individual braided wires but you can also try with multicore cables and single strand, it's all a matter of preference.
2. Four pin housing/connectors
  * Used to connect each microphone to BOB. This way only one BOB is needed for all three mics. The mics can be connected and disconnected. If the BOB breaks a new one can easily be made. Make sure the size you buy fits your PCB. We use 2.54mm ones.
3. Right angle mini XLR connectors
  * Go on the BOB. Send signals to audio interface for recording.
4. Mini XLR to XLR cables (x4)
  * To connect the BOB to the audio interface.
5. 3V coin cell BOB from Adafruit + headers.
  * Naturally you'll want some batteries as well. You can buy these anywhere, they are fairly ubiquitous.
  * The adafruit BOB was soldered to the protoboard.
  * In the future we want to make our own custom board.
6. A standard double-sided PCB to mount the coin cell BOB, hookup wire connectors and mini XLR connectors.
  * I ended up buying a "proto-board" since I'm a newby. That way you can build your circuit on a breadboard and then just replicate it exactly as is on the PCB.
7. A four channel audio interface
  * I bought a Behringer U-Phoria UMC404HD for $150. The only problem is that the knobs for the gain are analog, if you can get a cheap one with digital gain control that'd be better.
  * Make sure to never turn on phantom power, I am not sure what happens but I don't want to find out.
8. The PCB files we are using + OSH Park (online service) to produce them (or a Mill to DIY).
9. Some MEMS IC40720.
  * [These are the ones we used.](https://www.invensense.com/products/analog/ics-40720/)
  * Download the data-sheet to get the heat profile for the reflow oven.
  * Apply the paste to the PCBs and use tweezers to gently lay the capsules on, don't press down, the heat from the oven should take care of everything.
10. Solder paste
  * Used to surface mount the capsules unto the PCBs.
11. A reflow oven or home solution to surface mounting.
  * Note: unfortunately these are very hard to mount since the pads are not exposed during soldering. The best way to do it without a reflow oven is with an electric hot plate (as far as I know, have not tried it yet).
  * Some known solutions include: hot plates, DIY reflow ovens made from convection ovens and heat guns (that last one might be tricky for this).
12. A soldering station + solder.
  * You will use this to solder every component that needs soldering other than the MEMS capsule and the surface mounted capacitor.
  * It helps to have thin solder since the leads can get quite small and the thinner the solder the easier it will melt. Also recommend getting some "helping hands" to prop stuff up.
13. A 3D printer or a 3D printing service.
14. A laser cutter or a laser cutting service
  * We will use this to make foam rings that keep the PCBs in place.
  * This is sort of optional, it has worked really well for me.
15. The foam for the rings.
  * I bought some 2mm foam from Amazon. Beware when laser cutting. Fumes can be toxic. I am uncertain about the flammability of this material but I’ve laser cut it before successfully. [to do: laser cutter settings]
16. Reaper
  * Best DAW for this kind of work
17. Some free ambisonic software.
18. 0.1uF surface mounted capacitors.
  * [I believe these are the ones](https://www.digikey.com/product-detail/en/kemet/C0805C104K5RACTU/399-1170-1-ND/411445)
  * I am pretty sure they are diaelectric so it does not matter which direction you mount them in.

## Instructions (incomplete)

1. Use paste to solder MEMS capsule and capacitor in the reflow oven. Use the spec sheet to get the right heat curve, ensuring that no components are damaged.

2. Solder wires to the PCBS. We recommend having a consistent color code to make things easier. Also, the sound is going to be coming in from the "sound hole" opposite the capsule, so make sure your cables are pointed away.
  * We used this scheme:
    * Black = GRND
    * Red = V
    * White = +
    * Green = -
  * Whatever colors you have just be consistent and keep track of what color you are using for what purpose.


3. Check that the capsules are working by connecting them to a sound card and connecting the voltage leads to the battery. Or use an oscilloscope if you have one, this is generally faster.

4. After the cables have been soldered you have to feed them through the mic housing and careful fit the PCBs inside. It is important to label which capsule is going into what port. You should use tape and a sharpie for this step. The reason for this is that it will be impossible to trace the cables once inside the housing, and we will need to know which cables correspond to which capsule.


5. After that we made a cheap little breakout board that we soldered the signals to and made paths for the battery. It is our little black box were really no magic is happening (laughs). We made it so we can disconnect any capsule that might not be working and can replace it if need be. Getting the XLR pins is a bit tricky too but they have diagram for that online. We used mini XLRs to make the whole thing a bit neater.

6. Connect wires to a breakout board and battery to the circuit.

7. Connect audio signal to mini  XLR cables.

8. Record ambisonics A-format signals.

For even more information, check out our research!

## Code

Syntax highlighting

``` js
nothin to c hear
```


## Links

https://sites.google.com/s/0Bz2vToUDaO82b2thZ1JjelFhYVU/p/0Bz2vToUDaO82UkNDbG9HZGJRdDQ/edit

http://www.creativefieldrecording.com/2017/03/01/explorers-of-ambisonics-introduction/

https://wiki.xiph.org/Ambisonics

https://cm-gitlab.stanford.edu/ambisonics/SpHEAR/

https://en.wikipedia.org/wiki/List_of_Ambisonic_software

https://github.com/greekgoddj/ambisonic-lib


## Images

![Ambi Logo](https://upload.wikimedia.org/wikipedia/en/thumb/f/f6/AmbisonicLogo.svg/1200px-AmbisonicLogo.svg.png)
