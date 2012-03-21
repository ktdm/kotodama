class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title, :null => false
      t.string :url
      t.string :author, :default => "kotoda.ma"
      t.integer :views, :default => 0
      t.text :info
      t.text :html

      t.timestamps
    end
  end
end
