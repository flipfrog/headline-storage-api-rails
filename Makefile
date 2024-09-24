all: run

run:
	rails server -b 0.0.0.0 -p 80

migrate:
	rails db:migrate

test:
	bin/rspec spec/

act-test:
	act -j test --container-architecture linux/amd64

act-lint:
	act -j lint --container-architecture linux/amd64

act:
	act push --container-architecture linux/amd64

