class GoodreadsQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      begin
        client = Goodreads::Client.new(:api_key => 'tXnL9jUvUL7KMLQY6QnKQ ', :api_secret => 'yPqE0NtA2tvaWxFlStNM8mr8DTRCUafbdEWGA4RrLo ')

        results = client.search_books(user_keyword.keyword).results.work
        results = results.select { |result| !result['best_book']['image_url'].include?('/nophoto/') }
        len = results.count

        if len > 0
          results.each_with_index do |word, index|
            UserKeywordHit.create(
              user_keyword_id: user_keyword.id,
              provider: 'goodreads',
              uri: 'https://www.goodreads.com/book/show/' + word['best_book']['id'],
              content: word['best_book']['title'],
              score: ((len-index).to_f/len.to_f) * user_keyword.relevance,
              image_uri: word['best_book']['image_url'])
          end
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end

