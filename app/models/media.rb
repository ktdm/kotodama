class Media < ActiveRecord::Base
  include Url
  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  before_create do |media|
    media.title.capitalize!
  end
  after_create do |media|
    media.url = encode(media.id)
    media.save
  end
end
