class AddImageUriToUserKeywordHits < ActiveRecord::Migration
  def change
    add_column :user_keyword_hits, :image_uri, :string
  end
end
