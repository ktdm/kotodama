class MediaSweeper < ActionController::Caching::Sweeper
  observe Media

  def after_update(media)
    expire_page(:id => media.url)
  end
end
