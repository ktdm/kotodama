class MediaController < ApplicationController

  include Url
  include AddTables
  include InitMedia

  def show
    if params[:context].nil?
      media = Media.find( decode params[:id] )
      init_obj(media.data_type) unless Object.const_defined? media.data_type
      instance_variable_set("@" + media.title.downcase.pluralize, Media.where(:data_type => media.title)) if media.data_type == "Mediatype"
      instance_variable_set( "@" + media.data_type.downcase, media )
      case media.data_type
      when "Editor"
        new
      when "Mediatype"
        render :inline => Mediatype.find(1).script, :layout => "application"
      else
        render :inline => Media.where(:title => media.data_type, :data_type => "Mediatype")[0].data.script
      end
    else
      media = Media.find ( decode params[:context] )
      media.data_type == "Editor" ? edit : redirect_to(root_url + params[:id] + "/edit")
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    media = Media.find( decode params[:id] )
    init_obj(media.data_type) unless Object.const_defined? media.data_type
    mediatype = Media.where(:title => media.data_type, :data_type => "Mediatype")[0]
    editors = Editor.where(:mtype => mediatype.id)
    if params[:context].nil?
      editors.length > 0 ? redirect_to(root_url + encode( editors[0].media[0].id ) + "/" + params[:id])
                          : new #this will become "Edit new editor" once 'create Editor' is working
    elsif editors.length == 1
      if editors[0].media[0].id != decode(params[:context])
        redirect_to(root_url + params[:id] + "/edit")
      else
        mediatype.data.arguments[0].each do |w| # generalise for argument types?
          media.data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
        end
        @media = instance_variable_set( "@" + media.data_type.downcase, media )
        render "media/" + params[:context] + "/edit" #will mongo save my api??
      end
    elsif editors.length > 1
      render :inline => "duplicate id issue :("
    else
      redirect_to root_url + params[:id] + "/edit"
    end
  end

  def update
    media = Media.update( decode(params[:id]), params[:media] )
    mediatype = Media.where(:title => media.data_type)[0]
    mediatype.data.arguments[0].each do |w|
      params[mediatype.title.downcase.to_sym][w[0].to_sym].map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    Object.const_get(mediatype.title).update(media.data_id, params[mediatype.title.downcase.to_sym]).save
    media.save
    redirect_to edit_media_url
  end

  def new
    @showntype = "editor"
    @action = "create"
    mediatype = Media.find( Media.find( decode(params[:id]) ).data.mtype )
    mt = mediatype.title
    instance_variable_set( "@" + mt.downcase, Media.new(:title => "New " + mt.downcase, :info => "It's a new " + mt.downcase + "!", :url => "") ).data = Object.const_get(mt).new
    render "media/" + params[:id] + "/edit"
  end

  def create
    mediatype = Media.find( Media.find( decode(params[:id]) ).data.mtype )
    media = Media.new(params[:media])
    media.data = Object.const_get(mediatype.title).new(params[mediatype.title.downcase.to_sym])
    if mediatype.title == "Mediatype" # move to mediatype editor?
      basetype = {"Array" => "Text"}
      args = media.data.arguments[0].map {|x| [ x[0], basetype[x[1]] || x[1] ] }
      T.create( media.title.downcase.pluralize.to_sym, media.data.arguments[0] )
    end
    mediatype.count += 1
    mediatype.save
    mediatype.data.arguments[0].each do |w|
      media.data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    media.save
    media.data.save
    init_obj(media.title) if mediatype.title == "Mediatype"
    if mediatype.title == "Editor"
      path = Rails.root.join("app/views/media", media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + media.url
  end

end
