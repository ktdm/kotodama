include AddTables
include InitMedia

#Prepare tables
Media.delete_all
if Rails.env.production? #Condition on sqlite_sequence.exists?
  T.conn.reset_pk_sequence!('media')
else
  T.conn.execute "UPDATE sqlite_sequence SET seq=0 WHERE name='media';"
end

T.create( :mediatypes, { :arguments => :text, :script => :text } )
T.create( :editors, { :mtype => :integer, :forms => :text, :script => :text } )

#Seed data
Mediatype.create( :arguments => ["arguments" => "Array"], :script => IO.read(Rails.root.join("app/views/home/mediatype.html.erb")) ).media.create(:title => "Mediatype", :count => 2, :info => "Mediatype mediatype.")
Editor.create(:mtype => 1, :forms => []).media.create(:title => "Editmediatype", :info => "Mediatype editor.")
Mediatype.create( :arguments => ["mtype" => "Integer", "forms" => "Array"] ).media.create(:title => "Editor", :count => 2, :info => "Editor mediatype.")
Editor.create(:mtype => 3, :forms => []).media.create(:title => "Editeditor", :info => "Editor editor.")
