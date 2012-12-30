class Media < ActiveRecord::Base
  include Url
  include InitMedia
  belongs_to :data, :polymorphic => true
  belongs_to :mediatype, :class_name => "Media"
  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  before_create do |media|
    media.title.capitalize! if media.data_type == "Mediatype"
  end
  after_create do |media|
    media.url = encode media.id
    media.mediatype.count += 1
    media.save
    media.mediatype.save
  end
  before_save do |media|
    init_obj( media.data_type ) unless Object.const_defined? media.data_type
    media.mediatype.data.arguments.each do |w|
      media.data.send(w.keys[0]).delete_if {|x| x.empty? }.map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w.values[0].downcase=="array"
      #media.data.send(w.keys[0]).compact.inject(:"merge!") if w.values[0].downcase=="hash"
    end
  end
end

class Mediatype < ActiveRecord::Base
  include InitMedia
  has_many :media, :as => :data, :dependent => :destroy #has_one
  serialize :arguments, Array
  serialize :views, Array
  after_create "save_table('create')"
  after_update "save_table('alter')"
  protected
  def save_table(action) #separate
    init_obj(media[0].title) unless Object.const_defined? media[0].title
    basetype = {"Array" => "Text", "Hash" => "Text"}
    T.send(
      action,
      media[0].title.downcase.pluralize.to_sym,
      arguments.delete_if {|x| x.empty? }.map {|x| x.map {|y| { y[0] => (basetype[y[1]] || y[1]) } } }.flatten.inject({}) {|x,y| x.merge(y) }
    )
  end
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :data, :dependent => :destroy #has_one
#has_one :mediatype #rename mtype ..?
  serialize :forms, Array
  serialize :views, Array
end
