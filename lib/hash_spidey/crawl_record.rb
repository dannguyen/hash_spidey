require 'hashie'
require 'mechanize'

module HashSpidey
	
	class CrawlRecord < BasicObject

		META_ATTS = %w(crawled_timestamp title header code response_header_charset meta_charset detected_encoding content_type)
		attr_reader :crawled_timestamp

		def initialize(obj, timestamp)
			@crawled_timestamp = timestamp
			@page_object = obj
		end

		def to_hash
			msh = Hashie::Mash.new
			META_ATTS.each do |att|
				msh[att] = self.send(att) if self.respond_to?(att)
			end
			return msh
		end

		protected

		def method_missing(name, *args, &block)
			if @page_object.respond_to?(name)
			  @page_object.send(name, *args, &block)
			else
			  super
			end
		end

	end
end