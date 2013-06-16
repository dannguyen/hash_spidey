require 'addressable/uri'
require_relative 'crawl_record'

module HashSpidey
	class HashUrlRecord 

		attr_reader :url, :code,  
			:initialized_timestamp, :crawled_timestamp, :recorded_timestamp,
			:content, :handler, :spider, :handle_data,
			:crawl_metadata, :parsed_data


		# convenience name for spidey
		def self.spidey_handle(url, handler, spider, opts)
			mash_opts = Hashie::Mash.new opts 
			mash_opts.spider = spider
			mash_opts.handler = handler 

			return HashUrlRecord.new url, mash_opts
		end

		def initialize(url, opts={})
			@url = url
			@addressable_uri = Addressable::URI.parse(@url)
			@initialized_timestamp = Time.now 

			mash_opts = Hashie::Mash.new(opts) 
			@spider = mash_opts.delete :spider 
			@handler = mash_opts.delete :handler 
			@handle_data = mash_opts.delete :handle_data # not sure if needed?...
		end


		def mark_record(obj)
			obj = Hashie::Mash.new(obj) if obj.is_a?(Hash)

			@content = obj.content if obj.respond_to?(:content)
			@parsed_data = obj.parsed_data if obj.respond_to?(:parsed_data)
			@recorded_timestamp = Time.now
		end

		# saves data related
		def mark_as_crawled(page_obj={})
			@crawled_timestamp = Time.now
			# do something with mechanized page object
			@crawl_metadata = HashSpidey::CrawlRecord.new(page_obj, @crawled_timestamp)
		end

		def recorded?
			!(@recorded_timestamp.nil?)
		end

		def crawled?
			!(crawled_timestamp.nil?)
		end

		def has_content?
			!(@content.nil? || @content.empty?)
		end

		## this is just an alias

		# obvious smells
		def collected_timestamp; @recorded_timestamp; end 
		def header; @crawl_metadata.header unless @crawl_metadata.nil? ; end
		def code; @crawl_metadata.code unless @crawl_metadata.nil? ; end

		#### url inspection methods
		[:host, :port, :query, :scheme, :path ].each do |foo|
			define_method foo do 
				@addressable_uri.send foo 
			end
		end

		def query_values
			@addressable_uri.query_values
		end
	end
end