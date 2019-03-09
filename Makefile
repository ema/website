all: index.html upload

index.html:
	m4 index.html.m4 > index.html

upload:
	echo "put index.html index.html" | cadaver http://www2.linux.it/davhome/ema

clean:
	-rm index.html
