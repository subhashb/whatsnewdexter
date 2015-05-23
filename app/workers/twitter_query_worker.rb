require 'temboo'
require 'Library/Twitter'

class TwitterQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query
  
  def perform(user_keyword_id)
    user_keyword = UserKeyword.find(user_keyword_id)
    
    if user_keyword.present?
      begin
        # Instantiate the Choreo, using a previously instantiated TembooSession object, eg:
        session = ::TembooSession.new("whatsnew", "myFirstApp", "0b0a1162770942de8d747eaa88478dba")
        tweetsChoreo = Twitter::Search::Tweets.new(session)    
        tweetsInputs = tweetsChoreo.new_input_set()
        tweetsInputs.set_AccessToken("3189373974-mstMTaK0wF9fQwuhlzSZT7lEHuPyQo1ceb7Ol5d");    
        tweetsInputs.set_AccessTokenSecret("QjHHnXl8Uy9YhJunhA1ijVZuOu0MsUiGlHjJw1Pl685k0");    
        tweetsInputs.set_ConsumerKey("5wFwfIb6MDswRbdQ832QaSDji");
        tweetsInputs.set_ConsumerSecret("C3nk8ElBG4YF4C7kBa49UYVkYvpsRqLp6TZv9f3qOtHI3bWIWN");
      
        tweetsInputs.set_Query(user_keyword.keyword);

        tweetsString = tweetsChoreo.execute(tweetsInputs)

        tweetsData = JSON.parse(tweetsString.get_Response())["statuses"]
    
        if tweetsData.present?
          tweetsData.each_with_index do |data, index|
            UserKeywordHit.create_with_image_uri(
              user_keyword_id: user_keyword.id,
              provider: 'twitter',
              uri: "https://twitter.com/statuses/#{data['id_str']}",
              content: data['text'],
              score: (((tweetsData.length-index).to_f/tweetsData.length.to_f) * user_keyword.relevance))
          end
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end
