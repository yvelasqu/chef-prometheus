.PHONY: kitchen

dependencies:
	bundle install

rubocop: dependencies
	bundle exec rubocop --format progress --format html -o reports/rubocop/index.html

foodcritic: dependencies
	bundle exec foodcritic .

chefspec: dependencies
	bundle exec berks install && bundle exec rspec

check: rubocop foodcritic chefspec
