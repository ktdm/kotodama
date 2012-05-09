class MediaController < ApplicationController

  include Url
  include InitMedia

  def show
    if params[:id].nil?
      render "home/index"
    elsif params[:context].nil?
      media = Media.find( decode params[:id] )
      instance_variable_set( "@" + media.data_type.downcase, media )
      new if (@_mediatype = media.data_type) == "Editor"
      init_obj(@_mediatype) unless Object.const_defined? @_mediatype
      render :inline => media.mediatype.data.script, :layout => ( (["Mediatype", "Editor"].include? @_mediatype) ? "application" : false ) #media.author = kotoda.ma?
    else
      @_media = Media.find ( decode params[:context] )
      (@_mediatype = @_media.data_type) == "Editor" ? edit : redirect_to( root_url + Editor.where(:mtype => mediatype.title)[0].media[0].url + "/" + params[:id] ) #404?
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
        @_media.mediatype.data.arguments.each do |w| # generalise for argument types, *move to models*
          @_media.data.send(w.keys[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w.values[0]=="Array"
        end
        instance_variable_set( "@" + @_media.data_type.downcase, @_media )
        init_obj("Editor") unless Object.const_defined? "Editor"
        render :inline => Media.find(3).data.script, :layout => "application"
      else
        redirect_to( root_url + editors[0].media[0].url + "/" + params[:id] )
      end
    end
  end

  def update
    media = Media.update( decode(params[:id]), params[:media] )
    init_obj(media.data_type) unless Object.const_defined? media.data_type #
    media.data = Object.const_get(media.data_type).update(media.data_id, params[media.data_type.downcase.to_sym])
    media.mediatype.data.arguments.each do |w|
      media.data.send(w.keys[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w.values[0]=="Array"
    end
    media.save
    media.data.save
    redirect_to :back
  end

  def new #add :mediatype/new route later
    @_editor = Media.find( decode params[:id] )
    mediatype = Media.find( @_editor.data.mtype )
    mt = mediatype.title
    @_media = instance_variable_set( "@" + mt.downcase, Media.new(:title => "New " + mt.downcase, :info => "It's a new " + mt.downcase + "!", :url => "") )
    @_media.mediatype = mediatype
    init_obj(mt) unless Object.const_defined? mt #move to media model?
    @_media.data = Object.const_get(mt).new
  end

  def create
    media = Media.new(params[:media])
    editor = Media.find(decode(params[:id]))
    media.mediatype_id = editor.data.mtype
    init_obj(media.mediatype.title) unless Object.const_defined? media.mediatype.title #
    media.data = Object.const_get(media.mediatype.title).new(params[media.mediatype.title.downcase.to_sym])
    media.mediatype.count += 1
    media.mediatype.save
    editor.count += 1
    editor.save
    media.mediatype.data.arguments.each do |w|
      media.data.send(w.keys[0]).map! {|x| x.inject({}) {|y,z| y.merge({z[0]=>z[1]}) } } if w.values[0]=="Array"
    end
    media.data.media[0]=media
    media.save
    media.data.save
    init_obj(media.title) if media.data_type=="Mediatype"
    if media.data_type == "Editor" #delete when templates are called from database
      path = Rails.root.join("app/views/media", media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + media.url
  end

end
