# Digilent Pmod KYPD driver

Digilent Pmod KYPD driver is a module 

## Description

An in-depth paragraph about your project and overview of use.

## Getting Started

### Dependencies

This module has been written in a vendor-agnostic style, so there is no need to link any additional libraries.

### Using

This module has few parameters and signals which meaning has been described below:
```clk_freq
parameter real ClockFrequencyInMHz = 100.0
```
Frequency of the system clock attached to the "clk_i" input in MHz. Default value is 100 MHz.

```kypd_scann_freq
parameter real KeypadScanningFrequencyInMHz = 1.0
```
Frequency of the keypad scanning(refreshing) process. Default value is 1 MHz.

```clk_sig
input logic clk_i
input logic reset_i
```
Clocking and synchronous, active-high reset signals.

```kypd_if_sig
input  logic [3:0] kypd_rows_i
output logic [3:0] kypd_cols_o
```
Keypad rows and columns signals.

```
output logic [3:0] pressed_key_o
```
Signal that represents the pressed button in hex format, i.e. (0, 1, ..., F).

## Help

If you find any problems or issues with this module or the documentation, please check out the issue tracker and create a new issue if your problem is not yet tracked.

## Authors

* Hubert Zajączkowski

## License

Unless otherwise noted, everything in this repository is covered by the Apache License, Version 2.0 (see LICENSE for full text).
