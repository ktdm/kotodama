#Seed primary media
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

#Create data tables
class SeedTables
  def self.create(table, fields)
    ActiveRecord::Base.connection.drop_table(table)
    ActiveRecord::Base.connection.create_table(table)
    fields.each do |field, type|
      ActiveRecord::Base.connection.add_column(table, field, type)
    end
  end
end

SeedTables.create( :mediatypes, { :media_id => :integer, :arguments => :text } )
SeedTables.create( :editors, { :media_id => :integer, :mtype => :integer } )
#(You can use "pragma table_info(tableName)" in sqlite3 'as' schema.rb)

#Seed data tables
class Mediatypes < ActiveRecord::Base
  establish_connection(:development)
  serialize :arguments, Array
end

Mediatypes.create(:media_id => 1, :arguments => ["arguments" => "text"])
#Mediatypes.create(:media_id => 3, :arguments => ["mtype" => "integer"])

class Editors < ActiveRecord::Base
  establish_connection(:development)
end

Editors.create(:media_id => 2, :mtype => 1)
#Editors.create(:media_id => 4, :mtype => 2)
