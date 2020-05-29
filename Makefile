saltan: cleancl
	nimble build -d:ssl

release: cleancl
	nimble build -d:release -d:ssl

js: cleanjs
	nim js -d:ssl -o=jsaltan.js src/jsaltan.nim 

jsrelease: cleanjs
	nim js -d:ssl -o=jsaltan.js -d:release src/jsaltan.nim
	closure-compiler --js jsaltan.js --js_output_file \
	jsaltan-compiled.js --compilation_level=SIMPLE_OPTIMIZATIONS

all: saltan js

allrelease: release jsrelease

clean: cleancl cleanjs

cleancl:
	rm -f bin/saltan

cleanjs:
	rm -f jsaltan.js jsaltan-compiled.js
