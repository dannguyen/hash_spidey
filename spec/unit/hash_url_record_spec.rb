require 'spec_helper'

include HashSpidey
describe HashSpidey::HashUrlRecord do 


	context "delegate URI methods to Addressable::URI" do 

		before(:each) do 
			@hurl = HashUrlRecord.new 'http://www.example.com:80/stuff/?q=1&a=2&b=hello'
		end


		it 'should have #host' do 
			expect( @hurl.host ).to eq 'www.example.com'
		end

		it 'should have #port' do 
			expect( @hurl.port ).to eq 80
		end

		it 'should have #query' do 
			expect( @hurl.query ).to eq 'q=1&a=2&b=hello'
		end

		it 'should have #scheme' do 
			expect( @hurl.scheme ).to eq 'http'
		end

		it 'should have #path' do 
			expect( @hurl.path ).to eq '/stuff/'
		end
	end

	context "state changes upon record and crawl" do 
		before(:each) do 
			@hurl = HashUrlRecord.new "http://www.example.com"
		end

		describe '#mark_record' do 
			before(:each) do 
				@hurl.mark_record content: 'hello'
			end

			it 'should set @recorded_timestamp' do 
				expect( @hurl.recorded_timestamp ).to be_within(2).of Time.now
			end

			it 'should set @content' do 
				expect( @hurl.content ).to eq 'hello'
			end

			it 'should have #recorded? be true' do 
				expect( @hurl.recorded?).to be_true
			end
		end

		describe '#mark_as_crawled' do
			before(:each) do
				@hurl.mark_as_crawled
			end

			it 'should set @crawled_timestamp' do 
				expect( @hurl.crawled_timestamp ).to be_within(2).of Time.now
			end

			it 'should have #crawled? be true' do 
				expect( @hurl.crawled?).to be_true
			end
		end
	end

end