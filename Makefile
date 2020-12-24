test:
	rm -rf spec/dummy
	git clone git@github.com:purple-magic/tramway_test spec/dummy/
	cd spec/dummy && bundle install && rails db:create db:migrate
	rake
