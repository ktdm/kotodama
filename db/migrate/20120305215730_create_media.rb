class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :title, :null => false
      t.string :url
      t.string :author, :default => "kotoda.ma"
      t.integer :count, :default => 0
      t.text :info

      t.references :data, :polymorphic => true
      t.integer :mediatype_id
      t.integer :editor_id

      t.timestamps
    end
  end
end
