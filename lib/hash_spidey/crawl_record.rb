require 'hashie'
require 'mechanize'

module HashSpidey
	
	class CrawlRecord

		META_ATTS = %w(crawled_timestamp title header code response_header_charset meta_charset detected_encoding content_type)
		attr_reader :crawled_timestamp

		def initialize(obj, timestamp)
			@crawled_timestamp = timestamp


			@page_object = META_ATTS.inject(Hashie::Mash.new) do |msh, att|
				msh[att] = obj.send(att) if obj.respond_to?(att)
				msh
			end

			@page_object.crawled_timestamp = @crawled_timestamp
		end

		def to_hash			
			return @page_object
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