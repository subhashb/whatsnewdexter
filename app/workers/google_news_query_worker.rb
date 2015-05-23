class GoogleNewsQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query
  
  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)
    
    begin
      if user_keyword.present?
        len = Google::Search::News.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword.keyword).count

        if len > 0
          Google::Search::News.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword.keyword).each_with_index do |news, index|
            UserKeywordHit.create_with_image_uri(
              user_keyword_id: user_keyword.id,
              provider: 'google_news',
              uri: news.uri,
              content: news.content,
              score: (((len-index).to_f/len.to_f) * user_keyword.relevance))
          end
        end
      end
    rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
    end
  end
end

