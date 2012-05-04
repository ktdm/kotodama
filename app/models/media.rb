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
  belongs_to :editor, :class_name => "Media"
end

class Mediatype < ActiveRecord::Base
  has_many :media, :as => :data #has_one
  serialize :arguments, Array
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :data #has_one
  serialize :forms, Array
end
