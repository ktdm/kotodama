class MediaController < ApplicationController

  include Url
  include AddTables
  include InitMedia

  def show
    if params[:id].nil?
      @title = "Make and share websites on kotoda.ma"
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
    @_media.mediatype = Media.where(:title => @_media.data_type, :data_type => "Mediatype")[0]
    editors = Editor.where(:mtype => @_media.mediatype.id)
    if params[:context].nil?
      editors.length > 0 ? redirect_to( root_url + editors[0].media[0].url + "/" + params[:id] ) : redirect_to( root_url + encode(4) )
    else
      @_editor = Media.find(decode(params[:context]))
      if @_editor.data.mtype == @_media.mediatype.id
        @_media.mediatype.data.arguments.each do |w| # generalise for argument types? *move to models*
          @_media.data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
        end
        instance_variable_set( "@" + @_media.data_type.downcase, @_media )
        render :inline => Media.find(3).data.script, :layout => "application"
      else
        redirect_to( root_url + editors[0].media[0].url + "/" + params[:id] )
      end
    end
  end

  def update
    media = Media.update( decode(params[:id]), params[:media] )
    media.data = Object.const_get(media.data_type).update(media.data_id, params[media.data_type.downcase.to_sym])
    mediatype = Media.where(:title => media.data_type, :data_type => "Mediatype")[0]
    mediatype.data.arguments.each do |w|
      media.data.send(w.keys[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w.values[0]=="Array"
    end
    media.save
    media.data.save
#Add + remove columns if mediatype.title=Mediatype
    redirect_to :back
  end

  def new
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
    media.mediatype_id = Media.find( decode(params[:id]) ).data.mtype
    media.data = Object.const_get(media.mediatype.title).new(params[media.mediatype.title.downcase.to_sym])
    if media.data_type == "Mediatype" # move to mediatype editor?
      basetype = {"Array" => "Text"}
      args = media.data.arguments[0].map {|x| [ x[0], basetype[x[1]] || x[1] ] }
      T.create( media.title.downcase.pluralize.to_sym, media.data.arguments[0] )
    end
    media.mediatype.count += 1
    media.mediatype.save
    media.mediatype.data.arguments.each do |w|
      media.data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    media.save
    media.data.save
    init_obj(media.title) if media.data_type == "Mediatype"
    if media.data_type == "Editor"
      path = Rails.root.join("app/views/media", media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + media.url
  end

end
