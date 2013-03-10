COFFEE = ./node_modules/.bin/coffee

default: build
	
init:
	npm install

docs:
	# docco src/*.coffee

clean:
	rm -rf lib/

build: clean
	${COFFEE} -o lib/ -c src/

watch: clean
	${COFFEE} -o lib/ -cw src/

dist: clean init docs build test

publish: dist
	npm publish

# && coffee -c test/fieldkit.coffee
