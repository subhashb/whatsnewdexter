class UserKeywordHit < ActiveRecord::Base
  belongs_to :user_keyword
  delegate :analysis_type, :relevance, to: :user_keyword
  
  scope :top_10, ->{ where() }
  
  searchable do
    integer  "user_keyword_id", :references => UserKeyword
    string "provider"
    string "analysis_type"
    text   "content"
    float "score"
    time "created_at"
  end
  
  def self.searcher(keyword)
    search = UserKeywordHit.search do 
      fulltext keyword
      order_by(:score, :desc)
      #order_by(:created_at, :desc)
    end
    
    ap search.results.collect { |r| r.content }
  end

  def self.create_with_image_uri(params)
    params[:image_uri] = LinkThumbnailer.generate(params[:uri]).images.first.src.to_s rescue "/images/#{params[:provider]}_big.png"
    UserKeywordHit.create(params)
  end
end
