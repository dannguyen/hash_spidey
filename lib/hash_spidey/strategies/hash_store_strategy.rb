module HashSpidey
	module Strategies
		module HashStore

			def initialize(attrs = {})
				@url_collection = {}
				@error_collection = []
				agent.user_agent = "Abstract Spider"

				super(attrs)
			end

#### process strategies


			## conveinence methods 
			def crawls
				@url_collection.select{|k,v| v.crawled?}
			end


			def uncrawled
				@url_collection.reject{|k,v| v.crawled?}
			end

			def records
				@url_collection.select{|k,v| v.recorded?}
			end

			def process_crawl(url, page)
				h_url = @url_collection[url]
				h_url.mark_as_crawled(page)
			end


			def crawl(options = {})
				@crawl_started_at = Time.now
				@until = Time.now + options[:crawl_for] if options[:crawl_for]

				i = 0
				each_url do |url, handler, default_data|
					break if options[:max_urls] && i >= options[:max_urls]
					begin
						page = agent.get(url)
						Spidey.logger.info "Handling #{url.inspect}"
						send handler, page, default_data
						process_crawl(url, page)
					rescue => ex
						add_error url: url, handler: handler, error: ex
					end
					sleep request_interval if request_interval > 0
					i += 1
				end
			end


			def handle(url, handler, handle_data = {})
				Spidey.logger.info "Queueing #{url.inspect[0..200]}..."

				spider_name = self.class.name
				@url_collection[url] ||= HashUrlRecord.spidey_handle( url, handler, spider_name, handle_data )
			end

			# expects @url_collection to have :url, but if not, creates new HashUrlRecord  
			# data_hashie should have :content and/or :parsed_data
			def record(url, data_hashie)
				h_url = @url_collection[url] || HashUrlRecord.new(url)

				# set the content and record_timestamp of the HashUrlRecord
				h_url.mark_record(data_hashie)

				# reassign, update collection
				@url_collection[url] = h_url
			end

			# convenience method, expecting :page to be a Nokogiri::Page
			def record_page(page)
				url = page.uri.to_s
				record(url, content: page.content)
			end

			def record_data(page, data)
				url = page.uri.to_s
				record(url, parsed_data: data)
			end

			

			def each_url(&block)
				while h_url = get_next_url_hash
					yield h_url.url, h_url.handler, h_url.handle_data
				end
			end

			protected

			def add_error(attrs)
				@error_collection << attrs
				Spidey.logger.error "Error on #{attrs[:url]}. #{attrs[:error].class}: #{attrs[:error].message}"
			end


			private

			def get_next_url_hash
				return nil if (@until && Time.now >= @until)  # exceeded time bound
				# uncrawled is a filtered collection
				uncrawled.values.first 
			end
		end
	end
end