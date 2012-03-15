class CreateMediatypes < ActiveRecord::Migration
  def change
    create_table :mediatypes do |t|
      t.string :title, :null => false
      t.string :url
      t.string :author, :default => "kotoda.ma"
      t.integer :instances, :default => 0
      t.text :info
      t.text :script
      t.text :signature

      t.timestamps
    end
  end
end
