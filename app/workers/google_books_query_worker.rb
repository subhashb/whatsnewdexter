class GoogleBooksQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    begin
      if user_keyword.present?
        len = Google::Search::Book.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword.keyword).count

        if len > 0
          Google::Search::Book.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword.keyword).each_with_index do |book, index|
            UserKeywordHit.create(
              user_keyword_id: user_keyword.id,
              provider: 'google_books',
              uri: book.uri,
              content: book.title,
              score: (((len-index).to_f/len.to_f) * user_keyword.relevance),
              image_uri: book.thumbnail_uri)
          end
        end
      end
    rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
    end
  end
end

