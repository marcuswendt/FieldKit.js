# PATH := ./node_modules/.bin:${PATH}

init:
	npm install

docs:
	# docco src/*.coffee

clean:
	rm -rf lib/

build: clean
	coffee -o lib/ -c src/ 
	# && coffee -c test/fieldkit.coffee

watch: clean
	coffee -o lib/ -cw src/ 

dist: clean init docs build test

publish: dist
	npm publish