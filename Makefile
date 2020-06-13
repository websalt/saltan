# Compile the command-line version
saltan: cleancl
	nimble build -d:ssl

release: cleancl
	nimble build -d:release -d:ssl

# Maximum speed
# Maximum risk
danger: cleancl
	nimble build -d:danger --passc:-flto

# Compile the JavaScript version
# This doesn't actually work with the index.html
# jsrelease should be used instead
js: cleanjs
	nim js -d:ssl -o=jsaltan.js src/jsaltan.nim 

jsrelease: cleanjs
	nim js -d:ssl -o=jsaltan.js -d:release src/jsaltan.nim
	closure-compiler --js jsaltan.js --js_output_file \
	jsaltan-compiled.js --compilation_level=SIMPLE_OPTIMIZATIONS \
	--warning_level QUIET

# Compile everything
# allrelease should be used instead
all: saltan js

allrelease: release jsrelease

# Cleaning
clean: cleancl cleanjs

cleancl:
	rm -f bin/saltan

cleanjs:
	rm -f jsaltan.js jsaltan-compiled.js
