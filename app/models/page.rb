class Page < ActiveRecord::Base
  validates :title,
   :presence => true,
   :length => {:minimum => 1}
  #def to_param
  #  title #->url
  #end
end
