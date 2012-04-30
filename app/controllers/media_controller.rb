class MediaController < ApplicationController

  include Url
  include AddTables
  include InitMedia

  def show
    if params[:context].nil?
      media = Media.find( decode params[:id] )
      init_obj(media.data_type) unless Object.const_defined? media.data_type
      @media = Object.const_get(media.data_type).find(media.data_id)
      instance_variable_set("@" + @media.media[0].title.downcase.pluralize, Media.where(:data_type => media.title)) if media.data_type == "Mediatype"
      instance_variable_set( "@" + media.data_type.downcase, @media.media[0] )
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
    @media = Media.find( decode params[:id] )
    init_obj(@media.data_type) unless Object.const_defined? @media.data_type
    @mtype = Media.where(:title => @media.data_type, :data_type => "Mediatype")[0].data
    @editors = Editor.where(:mtype => @mtype.media[0].id)
    @editor_url = root_url + encode( @editors[0].media[0].id ) #add helper
    if params[:context].nil?
      @editors.length > 0 ? redirect_to(@editor_url + "/" + params[:id])
                          : new #this will become "Edit new editor" once 'create Editor' is working
    elsif @editors.length == 1
      if @editors[0].media[0].id != decode(params[:context])
        redirect_to(root_url + params[:id] + "/edit")
      else
        @data = Object.const_get( @media.data_type ).find( @media.data_id )
        instance_variable_set( "@" + @media.data_type.downcase, @data.media[0] )
        @mtype.arguments[0].each do |w| # generalise for argument types?
          @data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
        end
        render "media/" + params[:context] + "/edit" #will mongo save my api??
      end
    elsif @editors.length > 1
      render :inline => "duplicate id issue :("
    else
      redirect_to root_url + params[:id] + "/edit"
    end
  end

  def update
    @media = Media.update( decode(params[:id]), params[:media] )
    @mtype = Media.where(:title => @media.data_type)[0].data
    @mtype.arguments[0].each do |w|
      params[:data][w[0].to_sym].map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    Object.const_get(@media.data_type).update( @media.data_id, params[:data] ).save
    @media.save
    redirect_to edit_media_url
  end

  def new
    @showntype = "editor"
    @action = "create"
    @mtype = Media.find( Media.find( decode(params[:id]) ).data.mtype )
    @data = Object.const_get(@mtype.title).new
    instance_variable_set( "@" + @mtype.title.downcase, @data.media.new(:title => "New " + @mtype.title.downcase, :info => "It's a new " + @mtype.title.downcase + "!", :url => "") )
    render "media/" + params[:id] + "/edit"
  end

  def create
    @mtype = Media.find( Media.find( decode(params[:id]) ).data.mtype )
    @data = Object.const_get(@mtype.title).new(params[:data])
    @media = @data.media.new(params[:media])
    if @media.data_type == "Mediatype" # move to mediatype editor?
      basetype = {"Array" => "Text"}
      args = @data.arguments[0].map {|x| [ x[0], basetype[x[1]] || x[1] ] }
      T.create( @media.title.downcase.pluralize.to_sym, @data.arguments[0] )
    end
    @mtype.count += 1
    @mtype.save
    @mtype.data.arguments[0].each do |w|
      @data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    @media.save
    @data.save
    init_obj(@media.title) if @media.data_type == "Mediatype"
    if @media.data_type == "Editor"
      path = Rails.root.join("app/views/media", @media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + @media.url
  end

end
