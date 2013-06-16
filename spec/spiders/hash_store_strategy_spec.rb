require 'spec_helper'

describe HashSpidey::Strategies::HashStore do 

	before(:each) do 

	end


	class TestSpider < HashSpidey::AbstractSpider
		DEFAULT_REQUEST_INTERVAL = 0.001

		include HashSpidey::Strategies::HashStore
		def process_size(npage, data={})
			npage.inspect
		end

	end

	context 'generic #handle' do 

		before(:each) do 
			FakeWeb.register_uri(:get, "http://www.example.com/", :body => "Hello World", code: 200,
				"content-type"=>"text/html; charset=UTF-8"
				)
			@spider = TestSpider.new request_interval: 0
			@spider.handle "http://www.example.com/", :process_size
			@spider.crawl 
		end

		describe '#crawls' do 
			it 'should only add to #crawls' do 
				expect( @spider.crawls.count ).to eq 1
				expect( @spider.records.count ).to eq 0
			end

			it 'should update #crawled_timestamp' do 
				@crawled_url = @spider.crawls.values.first 
				expect( @crawled_url.url ).to eq 'http://www.example.com/'
				expect( @crawled_url.crawled_timestamp > @crawled_url.initialized_timestamp).to be_true
			end

			it 'should have #crawls act as a Hash' do 
				expect( @spider.crawls['http://www.example.com/'].url).to eq 'http://www.example.com/'
			end

			it "should not add duplicate URLs" do
				@spider.handle "http://www.example.com/", :process_something_else # second time			    
				expect( @spider.crawls.count ).to eq 1
			end

			context '@crawl_record' do 
				before(:each) do 
					@crawled_url = @spider.crawls["http://www.example.com/"]
				end

				it 'should respond to #code' do 
					expect(@crawled_url.code).to eq '200'
				end

				it 'should respond to header#content-type' do 
					expect(@crawled_url.crawleheader['content-type']).to eq "text/html; charset=UTF-8"
				end
			end
		end
	end


	context 'generic #record' do 
		describe '#records' do 
			before(:each) do 

				@data = Hashie::Mash.new url: 'http://www.example.com/', content: 'Hello World'
				@spider = TestSpider.new request_interval: 0
				@spider.record @data
			end		

			it "should add to records" do 
				expect(@spider.records.count).to eq 1
				expect(@spider.records['http://www.example.com/'].content).to eq 'Hello World'
			end

			it 'should update existing result' do 
				@spider.record Hashie::Mash.new url: 'http://www.example.com/', content: 'Bye World'
				expect(@spider.records['http://www.example.com/'].content).to eq 'Bye World'
				expect(@spider.records.count).to eq 1
			end
		end	
	end
end