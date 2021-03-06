
BASE ?= 0x8000
SRECORD_D ?=0
XLOAD_D ?=0
IRQINSTALL_D ?= 0

SHELL=/bin/tcsh -f

all: boot816.bin irqhandler.srec

clean:
	rm -f *.o *.lst *.srec *.bin

%.o : %.as
	ca65 -l $<.log $< -D BASE=$(BASE) -D IRQINSTALL_D=${IRQINSTALL_D} -D SRECORD_D=${SRECORD_D} -D XLOAD_D=${XLOAD_D}

%.bin: %.o
	cl65 $< --target none --start-addr $(BASE) -o $@

%.srec: %.bin
	srec_cat $< > $@ -Binary -offset $(BASE) -crlf -data-only
	awk '/PAGE/,/RUN/' srec2telnet
	cat $@
	echo S1x

%.ssd: %.bin
	cp $< tmp
	echo "\044.$*\t8000\t8000" > tmp.inf
	rm -f          $@
	beeb blank_ssd $@
	beeb title     $@ $*
	beeb putfile   $@ tmp
	beeb info      $@
	rm -f tmp tmp.inf
