.PHONY: *

default: test

build:
	rm -f *.gem
	gem build sigt.gemspec

publish: build
	gem push *.gem

console:
	irb -Ilib:spec -rspec_helper.rb

test:
	ruby -Ilib:spec -rpry spec/*_spec.rb
