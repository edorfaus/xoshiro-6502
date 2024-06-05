LDCFG = linker.cfg

CAFLAGS = -g -t nes $(EXTRA_CAFLAGS)
LDFLAGS = -C $(LDCFG)

# Do not treat any files as intermediate; they should not be deleted.
.NOTINTERMEDIATE:

.PHONY: all clean distclean

all: build/tests.nes

clean:
	$(if $(wildcard build/*),-,@echo )rm build/*

distclean:
	-[ ! -d build ] || rm -r build/

# Do not (try to) delete the created dir on error or if intermediate.
.PRECIOUS: %/
%/:
	mkdir -p $@

$(addprefix build/tests.,nes dbg map)&: build/main.o $(LDCFG)
	ld65 -o $(basename $@).nes.tmp $(LDFLAGS) \
		--dbgfile $(basename $@).dbg -m $(basename $@).map \
		$(filter-out $(LDCFG),$^)
	mv $(basename $@).nes.tmp $(basename $@).nes

build/main.o: nes2header.inc core.asm graphics.asm testdata.asm
build/main.o: ../xoshiro/* ../xoroshiro/*

build/%.o: %.asm | build/
	ca65 $(CAFLAGS) -o $@ $<
