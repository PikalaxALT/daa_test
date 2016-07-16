PYTHON := python

.SUFFIXES:
.PHONY: all clean daa_test
.SECONDEXPANSION:
.PRECIOUS: %.2bpp %.1bpp %.png %.asm %.c %.blk %.tilemap %.pal %.lz

poketools := extras/pokemontools
gfx       := $(PYTHON) gfx.py
includes  := $(PYTHON) $(poketools)/scan_includes.py

daa_test_obj := daa_test.o

roms := daa_test.gbc

all: $(roms)
daa_test: daa_test.gbc

clean:
	rm -f $(roms) $(daa_test_obj)  $(roms:.gbc=.map) $(roms:.gbc=.sym)

%.asm: ;

%.o: dep = $(shell $(includes) $(@D)/$*.asm)
%.o: %.asm $$(dep)
	rgbasm -o $@ $<

daa_test.gbc: $(daa_test_obj)
	rgblink -n daa_test.sym -m daa_test.map -p 0x00 -o daa_test.gbc daa_test.o
	rgbfix -cjv -k 00 -l 0x33 -m 0x09 -p 0 -r 02 daa_test.gbc

%.png: ;
%.2bpp: %.png ; $(gfx) 2bpp $<
%.1bpp: %.png ; $(gfx) 1bpp $<
%.lz: % ; $(gfx) lz $<
