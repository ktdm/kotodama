# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Add Mediatype mediatype to media
Media.delete_all
if Rails.env.production?
  ActiveRecord::Base.connection.reset_pk_sequence!('media')
else
  ActiveRecord::Base.connection.execute "UPDATE sqlite_sequence SET seq=0 WHERE name='media';"
end

Media.create(:title => "mediatype", :mtype => "Mediatype", :info => "Mediatype mediatype.")
Media.create(:title => "editmediatype", :mtype => "Editor", :info => "Mediatype editor.")
#Media.create(:title => "editor", :mtype => "Mediatype", :info => "Editor mediatype.")
#Media.create(:title => "editeditor", :mtype => "Editor", :info => "Editor editor.")

#Create tables
class SeedTables
  def self.create(table, fields)
    ActiveRecord::Base.connection.drop_table(table)
    ActiveRecord::Base.connection.create_table(table)
    fields.each do |field, type|
      ActiveRecord::Base.connection.add_column(table, field, type)
    end
  end
end

SeedTables.create( :mediatypes, { :media_id => :integer, :signature => :text } )
SeedTables.create( :editors, { :media_id => :integer, :mtype => :integer } )
#(You can use "pragma table_info(tableName)" in sqlite3 'as' schema.rb)

#Add Mediatype data to mediatypes
class Mediatypes < ActiveRecord::Base
  establish_connection(:development)
  serialize :signature, Array
end

Mediatypes.create(:media_id => 1, :signature => ["signature" => "text"])
#Mediatypes.create(:media_id => 3, :signature => ["mtype" => "integer"])

class Editors < ActiveRecord::Base
  establish_connection(:development)
end

Editors.create(:media_id => 2, :mtype => 1)
#Editors.create(:media_id => 4, :mtype => 2)
