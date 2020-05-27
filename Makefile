saltan: clean
	nimble build -d:ssl

js: clean
	nim js -d:ssl src/jsaltan.nim

release: clean
	nimble build -d:release -d:ssl

jsrelease: clean
	nim js -d:ssl -d:release src/jsaltan.nim

all: clean
	nimble build -d:ssl
	nim js -d:ssl src/jsaltan.nim

allrelease: clean
	nimble build -d:release -d:ssl
	nim js -d:ssl -d:release src/jsaltan.nim

clean:
	rm -f saltan src/saltan src/jsaltan.js jsaltan.js
