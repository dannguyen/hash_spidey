module HashSpidey
	module Strategies
		module HashStore

			def initialize(attrs = {})
				@url_collection = {}
				@error_collection = []

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
						process_crawl(url, page)
						send handler, page, default_data
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
			def record(data_hashie)
				url = data_hashie.url
				h_url = @url_collection[url] || HashUrlRecord.new(url)

				# set the content and record_timestamp of the HashUrlRecord
				h_url.record_content(data_hashie.content)

				# reassign, update collection
				@url_collection[url] = h_url
			end


			# wrapper around #record 
			def record_page(page, default_data={})
				msh = Hashie::Mash.new(default_data)
				msh.url = page.uri.to_s
				msh.content = page.content

				record(msh) 
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