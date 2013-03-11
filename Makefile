COFFEE = ./node_modules/.bin/coffee

default: build
	
docs:
	# docco src/*.coffee

clean:
	rm -rf lib/

build: clean
	${COFFEE} -o lib/ -c src/

watch: clean
	${COFFEE} -o lib/ -cw src/

dist: clean docs build test

publish: dist
	npm publish


# && coffee -c test/fieldkit.coffee
# ${COFFEE} -o lib/ -j lib/fieldkit.js src/