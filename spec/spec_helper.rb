require 'hash_spidey'
require 'fakeweb'

RSpec.configure do |config|
	config.filter_run_excluding :skip => true
	config.formatter = :documentation # :progress, :html, :textmate
	config.fail_fast = true
	config.before(:each) do
	end

	config.after(:each) do
	end
end


