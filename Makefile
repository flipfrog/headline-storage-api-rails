all: run

run:
	rails server -b 0.0.0.0 -p 80

migrate:
	rails db:migrate

test:
	bin/rspec spec/

