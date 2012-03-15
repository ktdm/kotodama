class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :handle
      t.string :url

      t.timestamps
    end
  end
end
