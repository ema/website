DESTS = index.html systemtap-intro.html

all: $(DESTS)

%.html: %.html.m4
	m4 $< > $@

upload: *.html
	for file in $^; do echo "put $${file} ${{file}" | cadaver http://www2.linux.it/davhome/ema; done

clean:
	-rm $(DESTS)
