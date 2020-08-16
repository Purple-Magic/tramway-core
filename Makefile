updated_tests:
	rm -rf spec/dummy
	git clone git@github.com:purple-magic/tramway_test spec/dummy/
	cd spec/dummy && bundle install && rails db:create db:migrate
	rake

github_actions_test:
	cd tramway_test && bundle install && rails db:create db:migrate
	rake
