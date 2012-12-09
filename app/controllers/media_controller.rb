class MediaController < ApplicationController

  append_view_path MediatypeResolver.new

  include Url
  include InitMedia

  def show
    params[:id] = "i" if params[:id].nil? #Frontpage.find(1).media[0].url
    request.fullpath[1] = "i" if request.fullpath == "/"
    if params[:context].nil?
      media = Media.find( decode params[:id] )
      instance_variable_set( "@" + media.data_type.downcase, media )
      new if (@_mediatype = media.data_type) == "Editor"
      init_obj(@_mediatype) unless Object.const_defined? @_mediatype
      render request.fullpath, :layout => ( (["Mediatype", "Editor", "Frontpage"].include? @_mediatype and ["html", nil].include? params[:format]) ? "application" : false ) #layouts... as mediatype?? (Eg "layout:g" where u the Home mediatype url)
    else
      @_media = Media.find ( decode params[:context] )
      if request.fullpath.index(".").nil?
        (@_mediatype = @_media.data_type) == "Editor" ? edit : redirect_to( root_url + Editor.where(:mtype => mediatype.title)[0].media[0].url + "/" + params[:id] ) #404?
      else
        render request.fullpath[1..-1], :layout => false
      end
    end
  end

  def edit
    @_media = Media.find( decode params[:id] )
    init_obj(@_media.data_type) unless Object.const_defined? @_media.data_type
    editors = Editor.where(:mtype => @_media.mediatype.id)
    if params[:context].nil?
      editors.length > 0 ? redirect_to( root_url + editors[0].media[0].url + "/" + params[:id] ) : redirect_to( root_url + encode(4) )
    else
      @_editor = Media.find(decode(params[:context]))
      if @_editor.data.mtype == @_media.mediatype.id
        instance_variable_set( "@" + @_media.data_type.downcase, @_media )
        init_obj("Editor") unless Object.const_defined? "Editor"
#render url, :layout => "application"
        render request.fullpath[1..-1], :layout => "application"
      else
        redirect_to( root_url + editors[0].media[0].url + "/" + params[:id] ) #preferences?
      end
    end
  end

  def update
    media = Media.update( decode(params[:id]), params[:media] )
    init_obj(media.data_type) unless Object.const_defined? media.data_type
    media.data = Object.const_get(media.data_type).update(media.data_id, params[media.data_type.downcase.to_sym])
    media.save
    media.data.save
    redirect_to :back #causing chrome issue on update javascript
  end

  def new #add :mediatype/new route later
    @_editor = Media.find( decode params[:id] )
    mediatype = Media.find( @_editor.data.mtype )
    mt = mediatype.title
    @_media = instance_variable_set( "@" + mt.downcase, Media.new(:title => "New " + mt.downcase, :info => "It's a new " + mt.downcase + "!", :url => "") )
    @_media.mediatype = mediatype
    init_obj(mt) unless Object.const_defined? mt
    @_media.data = Object.const_get(mt).new
  end

  def create
    media = Media.new(params[:media])
    editor = Media.find(decode(params[:id]))
    media.mediatype_id = editor.data.mtype
    init_obj(media.mediatype.title) unless Object.const_defined? media.mediatype.title
    media.data = Object.const_get(media.mediatype.title).new(params[media.mediatype.title.downcase.to_sym])
    editor.count += 1
    editor.save
    media.data.media[0] = media
    media.save
    media.data.save
    redirect_to media_url + "/" + media.url
  end

end
