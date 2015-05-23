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
    image = LinkThumbnailer.generate(params[:uri]).images.first
    begin
      params[:image_uri] = image.src.to_s
      params[:image_width] = image.size[0]
      params[:image_height] = image.size[1]
    rescue
      params[:image_uri] = "/images/#{params[:provider]}_big.png"
      params[:image_width] = 100
      params[:image_height] = 100
    end
    UserKeywordHit.create(params)
  end
end
