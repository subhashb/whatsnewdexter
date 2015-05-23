class AddImageSizesToUserKeywordHits < ActiveRecord::Migration
  def change
    add_column :user_keyword_hits, :image_width, :integer
    add_column :user_keyword_hits, :image_height, :integer
  end
end
