class PublishDate < ActiveRecord::Migration[7.1]
  def change
    rename_column :posts, :data_publicacao, :published_date
  end
end
