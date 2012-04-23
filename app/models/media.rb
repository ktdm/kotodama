class Media < ActiveRecord::Base
  include Url
  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  before_create do |media|
    media.title.capitalize!
    media.mtype.capitalize!
  end
  after_create do |media|
    media.url = encode media.id
    media.save
  end
  has_many :mediatypes
  has_many :editors
end
