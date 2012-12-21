class MediaSweeper < ActionController::Caching::Sweeper
  observe Media

  def after_update(media)
    Media.where("mediatype_id = ?", media.id).each do |instance|
      expire_page(/\/#{instance.url}\/[^\/]*/)
#      expire_page("/" + instance.url, :id => /.*/)
    end
    expire_page("/" + media.url)
puts Rails.cache.instance_variables.to_s
expire_page("/b/c")
  end
end
