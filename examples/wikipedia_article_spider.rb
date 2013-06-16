# obviously, you should just use Wikipedia's API
class WikipediaArticleSpider < HashSpidey::AbstractSpider

   def initialize(first_article_url, opts)
      super(opts)
      handle first_article_url, :process_article
   end

   def process_article(page, default_opts={})

      record_page(page)

      page.search('a').select{|a| a['href'] =~ /wiki\/Category:/}.each do |a|
         href = resolve_url( a['href'], page)
         handle href, :process_category_page
      end
   end

   def process_category_page(page, default_opts={})
      title = page.title
      page_count_text = page.search('#mw-pages > p')[0].text.match(/[\d,]+ total\./)
      datastr = "#{title} has #{page_count_text}"

      record_data(page, datastr)
   end


end