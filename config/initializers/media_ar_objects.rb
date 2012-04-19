Object.const_set( "Mediatypes", Class.new(ActiveRecord::Base) {
  establish_connection(:development)
  belongs_to :media
  serialize :arguments, Array
} )
Object.const_set( "Mediatype", Class.new(ActiveRecord::Base) {
  establish_connection(:development)
})
Object.const_set( "Editors", Class.new(ActiveRecord::Base) {
  establish_connection(:development)
  belongs_to :media
  serialize :forms, Array
} )
Object.const_set( "Editor", Class.new(ActiveRecord::Base) {
  establish_connection(:development)
} )
