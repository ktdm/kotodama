class Media < ActiveRecord::Base
  include Url

  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  before_create do |media|
    media.title.capitalize!
  end
  after_create do |media|
    media.url = encode media.id
    media.save
  end
  belongs_to :data, :polymorphic => true
  belongs_to :mediatype, :class_name => "Media"
end

class Mediatype < ActiveRecord::Base
  include InitMedia

  has_many :media, :as => :data, :dependent => :destroy #has_one
  serialize :arguments, Array
  after_update do |mediatype|
    basetype = {"Array" => "Text"}
    T.alter(
      mediatype.media[0].title.downcase.pluralize.to_sym,
      mediatype.arguments.map {|x| x.map {|y| { y[0] => (basetype[y[1]] || y[1]) } } }.flatten.inject({}) {|x,y| x.merge(y) }
    )
  end
  after_create do |mediatype|
    basetype = {"Array" => "Text"}
    T.create(
      mediatype.media[0].title.downcase.pluralize.to_sym,
      mediatype.arguments.map {|x| x.map {|y| { y[0] => (basetype[y[1]] || y[1]) } } }.flatten.inject({}) {|x,y| x.merge(y) }
    )
  end
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :data, :dependent => :destroy #has_one
  serialize :forms, Array
end
