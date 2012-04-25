class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :title, :null => false
      t.string :url
      t.string :author, :default => "kotoda.ma"
      t.integer :count, :default => 0
      t.text :info

      t.references :mdata, :polymorphic => true

      t.timestamps
    end
  end
end
