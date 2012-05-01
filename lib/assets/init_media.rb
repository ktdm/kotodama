module InitMedia
  def init_obj(title)
#    Object.const_set( title.pluralize, Class.new(ActiveRecord::Base) {
#      establish_connection(:development)
#      has_many :media, :as => :data
#    } )
    Object.const_set( title, Class.new(ActiveRecord::Base) {
      establish_connection(:development)
      has_many :media, :as => :data
    } )
    Media.where(:title => title)[0].data.arguments.each do |x|
      Object.const_get(title).class_eval "serialize :#{x[0]}, Array" if x[1]=="Array"
    end
  end
end
