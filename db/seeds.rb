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
Media.create(:title => "editor", :mtype => "Mediatype", :info => "Editor mediatype.")
Media.create(:title => "editeditor", :mtype => "Editor", :info => "Editor editor.")

T.create( :mediatypes, { :media_id => :integer, :arguments => :text, :script => :text } )
T.create( :editors, { :media_id => :integer, :mtype => :integer, :forms => :text, :script => :text } )

#Seed data tables
Mediatypes.create( :media_id => 1, :arguments => ["arguments" => "Array"], :script => IO.read(Rails.root.join("app/views/home/mediatype.html.erb")) )
Mediatypes.create( :media_id => 3, :arguments => ["mtype" => "Integer", "forms" => "Array"] )

Editors.create(:media_id => 2, :mtype => 1, :forms => [])
Editors.create(:media_id => 4, :mtype => 3, :forms => [])
