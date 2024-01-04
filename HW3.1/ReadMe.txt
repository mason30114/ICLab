Timing analysis:

smart:  1.2392 (data required time)
lut256: 1.1582 (data required time)

Timing of smart is slightly greater than lut256.
I guess that's because the 3-steps calculation process of smart algorithm takes more time.



Area analysis:

smart:  2461.716055  (total area)
lut256: 26408.556589 (total area)

Total area of lut256 is enormously greater than smart.
I guess that's because there're a huge number of cells(ex: logic gates) after synthesizing the 256-inputs MUX.



Power analysis:

smart:  0.2244  (Dynamic)  6.21e+04  (Leakage)   0.225  (Total)
lut256: 0.5800  (Dynamic)  6.99e+05  (Leakage)   0.581  (Total)

Power consumption of lut256 is greater than smart.
I guess that's because we need more current(paths) to operate a 256-inputs MUX.