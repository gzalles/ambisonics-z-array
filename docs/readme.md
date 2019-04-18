# MEMS FOA Mic

## About
This is a first order ambisonic microphone that uses MEMS {analog} capsules (ICS-40720). This repository contains instructions to make your own system as well as code to help you process your recordings, encode the data, and will in the future contain a more sophisticated version of this project which allows for USB connectivity. The repo also has 3D models which you can print.

## Why

Ambisonic hardware is extremely expensive and hard to come by. MEMS capsules are cool because they have great part-to-part consistency. Over the years their SNR and frequency response have improved drastically. With a little bit of processing before encoding we can get a decent ambisonic recording that's made from parts costing around $50. The size of these capsules also make it possible to theoretically achieve distortion free pressure gradients well above 20kHz.

## What

1. CAD models
2. Gerber files
3. Matlab functions
4. Instructions

## Materials
1. 30 gauge AWG wire
  * Used to connect multiple PCBs with MEMS to BOB (Breakout Board) via pin housing. BOB used to supply 3V to MEMS in lieu of complicated step-down circuit relying on phantom power (48V).
2. Four pin housing/connectors
  * Used to connect each microphone to BOB. This way only one BOB is needed for all three mics. The mics can be connected and disconnected. If the BOB breaks a new one can easily be made. Make sure the size you buy fits your PCB.
3. Right angle mini XLR connectors
  * Go on the BOB. Send signals to audio interface for recording.
4. Mini XLR to XLR cables (x4)
  * To connect the BOB to the audio interface.
5. 3V coin cell BOB from Adafruit + headers.
  * Naturally you'll want some batteries as well. You can buy these anywhere, they are fairly ubiquitous.
6. A standard double-sided PCB to mount the coin cell BOB, hookup wire connectors and mini XLR connectors.
  * I ended up buying a "proto-board" since I'm a newby. That way you can build your circuit on a breadboard and then just replicate it exactly as is on the PCB.
7. A four channel audio interface
  * I bought a Behringer U-Phoria UMC404HD for $150. The only problem is that the knobs for the gain are analog, if you can get a cheap one with digital gain control that'd be better.
8. The PCB files we are using + OSH Park (online service) to produce them (or a Mill to DIY).
9. Some MEMS IC40720.
10. Solder paste
  * Used to surface mount the capsules unto the PCBs.
11. A reflow oven or home solution to surface mounting.
  *Note: unfortunately these are very hard to mount since the pads are not exposed during soldering. The best way to do it without a reflow oven is with an electric hot plate (as far as I know, have not tried it yet).
12. A soldering station + solder.
13. A 3D printer or a 3D printing service.
14. A laser cutter or a laser cutting service
  * We will use this to make foam rings that keep the PCBs in place.
  * This is sort of optional, it has worked really well for me.
15. The foam for the rings.
  * I bought some 2mm foam from Amazon. Beware when laser cutting. Fumes can be toxic. I am uncertain about the flammability of this material but I’ve laser cut it before successfully. [to do: laser cutter settings]
16. Reaper
  * Best DAW for this kind of work
17. Some free ambisonic software.

## Instructions

## Code

Syntax highlighting

``` js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```


## Links

[link text](http://dev.nodeca.com)


## Images

![Minion](https://octodex.github.com/images/minion.png)

With a reference later in the document defining the URL location:

[id]: https://octodex.github.com/images/dojocat.jpg  "The Dojocat"
