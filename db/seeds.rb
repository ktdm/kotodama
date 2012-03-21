include AddTables

#Seed primary media
Media.delete_all
if Rails.env.production? #Condition on sqlite_sequence.exists?
  T.conn.reset_pk_sequence!('media')
else
  T.conn.execute "UPDATE sqlite_sequence SET seq=0 WHERE name='media';"
end

Media.create(:title => "mediatype", :mtype => "Mediatype", :info => "Mediatype mediatype.")
Media.create(:title => "editmediatype", :mtype => "Editor", :info => "Mediatype editor.")
#Media.create(:title => "editor", :mtype => "Mediatype", :info => "Editor mediatype.")
#Media.create(:title => "editeditor", :mtype => "Editor", :info => "Editor editor.")

T.create( :mediatypes, { :media_id => :integer, :arguments => :text } )
T.create( :editors, { :media_id => :integer, :mtype => :integer } )
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
#Editors.create(:media_id => 4, :mtype => 3)
