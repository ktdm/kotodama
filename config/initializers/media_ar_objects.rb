class Mediatype < ActiveRecord::Base
  has_many :media, :as => :mdata
  serialize :arguments, Array
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :mdata
  serialize :forms, Array
end

#Object.const_set( "Mediatypes", Class.new(ActiveRecord::Base) {
#  establish_connection(:development)
#  has_one => :media, :as => :mdata
#  serialize :arguments, Array
#} )
#Object.const_set( "Mediatype", Class.new(ActiveRecord::Base) {
#  establish_connection(:development)
#  has_one => :media, :as => :mdata
#  serialize :arguments, Array
#})
#Object.const_set( "Editors", Class.new(ActiveRecord::Base) {
#  establish_connection(:development)
#  has_one => :media, :as => :mdata
#  serialize :forms, Array
#} )
#Object.const_set( "Editor", Class.new(ActiveRecord::Base) {
#  establish_connection(:development)
#  has_one => :media, :as => :mdata
#  serialize :forms, Array
#} )
