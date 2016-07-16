# daa_test
Short GBC ROM to test how different emulators handle the DAA opcode

## To set up the repository:
### Windows users:
Install the appropriate version of [Cygwin](http://www.cygwin.org) for your system architecture (i.e. if you're running 32-bit Windows, download the 32-bit setup.exe).

In the Cygwin installer, select the following packages: `python 2.7.*` `git` `make` `gettext`.

Launch Cygwin. Thence...

### Linux and OSX users:

Open Terminal. Thence...

### All systems:

... run the following commands:

    git clone https://github.com/bentley/rgbds
    cd rgbds
    make
    make install
    cd ..
    git clone --recursive https://github.com/pikalaxalt/daa_test
    cd daa_test
    make

Launch the resulting file `daa_test.gbc` in any Gameboy emulator.  When the ROM says "DAA TEST COMPLETE!", look for a file called `daa_test.sav` in whatever directory your emulator is configured to save battery files.

Some emulators such as VisualBoy Advance (VBA) do not support cartridges with always-accessible SRAM.  If the .sav file does not appear, the output is also stored in WRAM (c000 - dfff) in the same byte order as it would appear in the .sav file.  You can create a manual dump of WRAM to record the output.
