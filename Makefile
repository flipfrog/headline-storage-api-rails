all: run

run:
	rails server -b 0.0.0.0 -p 80

test:
	bin/rspec spec/

