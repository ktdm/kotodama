class Mediatype < ActiveRecord::Base
  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  serialize :signature, Array
  #def to_param
  #  title #->url
  #end
end
