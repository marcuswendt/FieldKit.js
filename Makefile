# Variables
BIN = ./node_modules/.bin
COFFEE = ${BIN}/coffee
BROWSERIFY = ${BIN}/browserify
UGLIFY = ${BIN}/uglifyjs


# Targets
default: dist

deps: 
	if test -d "node_modules"; then echo "dependencies installed"; else npm install; fi
	
clean:
	rm -rf lib/
	rm -rf build/

# compile the NPM library version to JavaScript
build: clean
	${COFFEE} -o lib/ -c src/

watch: clean
	${COFFEE} -o lib/ -cw src/

# compiles the NPM version files into a combined minified web .js library
web: build
	mkdir build/
	${BROWSERIFY} lib/fieldkit.js > build/fieldkit.js
	${UGLIFY} build/fieldkit.js > build/fieldkit.min.js

docs:
	# docco src/*.coffee

test:

dist: deps web

publish: dist
	npm publish