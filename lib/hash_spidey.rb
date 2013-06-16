require "hash_spidey/version"

require 'hashie'
require 'spidey'
require_relative 'hash_spidey/hash_url_record'
require_relative 'hash_spidey/strategies/hash_store_strategy'

module HashSpidey
	class AbstractSpider < Spidey::AbstractSpider
		include HashSpidey::Strategies::HashStore
	end
end
