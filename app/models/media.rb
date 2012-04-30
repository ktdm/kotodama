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
end

class Mediatype < ActiveRecord::Base
  has_many :media, :as => :data
  serialize :arguments, Array
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :data
  serialize :forms, Array
end
