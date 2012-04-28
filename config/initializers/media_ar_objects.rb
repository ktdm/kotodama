class Mediatype < ActiveRecord::Base
  has_many :media, :as => :mdata
  serialize :arguments, Array
end

class Editor < ActiveRecord::Base
  has_many :media, :as => :mdata
  serialize :forms, Array
end
