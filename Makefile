DESTS = index.html systemtap-intro.html

all: $(DESTS)

%.html: %.html.m4
	m4 $< > $@

upload: $(DESTS)
	echo "put $< $<" | cadaver http://www2.linux.it/davhome/ema

clean:
	-rm $(DESTS)
