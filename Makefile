saltan: clean
	nimble build -d:ssl

release: clean
	nimble build -d:release -d:ssl

js: clean
	nim js -d:ssl -o=jsaltan.js src/jsaltan.nim 

jsrelease: clean
	nim js -d:ssl -o=jsaltan.js -d:release src/jsaltan.nim
	closure-compiler --js jsaltan.js --js_output_file \
	jsaltan-compiled.js --compilation_level=SIMPLE_OPTIMIZATIONS

all: clean saltan js

allrelease: clean release jsrelease

clean:
	rm -f saltan jsaltan.js jsaltan-compiled.js
