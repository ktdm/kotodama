module InitMedia
  def init_obj(title)
    Object.const_set( title.pluralize, Class.new(ActiveRecord::Base) {
      establish_connection(:development)
      belongs_to :media
    } )
    Object.const_set( title, Class.new(ActiveRecord::Base) {
       establish_connection(:development)
    } )
    Mediatypes.where("media_id = ?", Media.where("title = ?", title)[0].id)[0].arguments.each do |x|
      Object.const_get(title).class_eval "serialize :#{x[0]}, Array" if x[1]=="Array"
    end
    Media.class_eval "has_many :#{title.downcase.pluralize}"
  end
end
