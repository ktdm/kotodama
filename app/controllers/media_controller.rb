class MediaController < ApplicationController

  include Url
  include AddTables

  def show
    if params[:context].nil?
      @media = Media.find( decode( params[:id] ) )
      unless Object.const_defined? @media.mtype.pluralize
        Object.const_set( @media.mtype.pluralize, Class.new(ActiveRecord::Base) {
          establish_connection(:development)
          belongs_to :media
        } )
        Object.const_set( @media.mtype, Class.new(ActiveRecord::Base) {
          establish_connection(:development)
          belongs_to :media
        } )
        Mediatypes.where("media_id = ?", Media.where("title = ?", @media.mtype)[0].id)[0].arguments.each do |x|
          Object.const_get(@media.mtype).class_eval "serialize :#{x[0]}, Array" if x[1]=="Array"
        end
        Media.class_eval "has_many :#{@media.mtype.pluralize}"
      end
      instance_variable_set("@" + @media.title.downcase.pluralize, Media.where( "mtype = ?", @media.title )) if ["Mediatype","Editor"].index(@media.mtype)
      instance_variable_set( "@" + @media.mtype.downcase, Object.const_get(@media.mtype.pluralize).where("media_id = ?", @media.id)[0] )
      case @media.mtype
      when "Editor"
        new
      when "Mediatype"
        render :inline => Mediatypes.find(1).script, :layout => "application"
      else
        render :inline => Mediatypes.where("media_id = ?", Media.where("title = ?", @media.mtype)[0].id)[0].script
      end
    else
      @media = Media.find ( decode( params[:context] ) )
      @media.mtype == "Editor" ? edit : render("media/" + params[:context] + "/index")
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    @media = Media.find( decode( params[:id] ) ) #find instance
    @mediatype = Mediatypes.where("media_id = ?", Media.where("title = ?", @media.mtype)[0].id)[0]
    @editors = Editors.where( "mtype = ?", @mediatype.media_id )
    @editor_url = root_url + encode( @editors[0].media_id ) #add helper
    if params[:context].nil? #find editor
      @editors.length > 0 ? redirect_to(@editor_url + "/" + params[:id])
                          : new #this will become "Edit new editor"
    elsif @editors.length == 1 #edit instance with its editor
#      redirect_to(root_url + params[:context]) if @editors[0].mtype != decode(params[:context])
      type = Media.find( @editors[0].mtype )
      instance_variable_set( "@" + type.title.downcase,
                             Media.joins( type.title.downcase.pluralize.to_sym ).where( "media_id = ?", @media.id )[0] )
      @title = "Edit mediatype '" + type.title + "' | kotoda.ma" #title should really be a in root_url/b/*a*
#also not mediatype : type.title
      @data = Object.const_get( type.title.pluralize ).where( "media_id = ?", @media.id )[0]
      render "media/" + params[:context] + "/edit" #will mongo save my api??
    elsif @editors.length > 1 #more than one editor
      render :inline => "duplicate id issue :("
    else #incorrect editor reference
      redirect_to root_url + params[:id] + "/edit"
    end
  end

  def update
    @media = Media.update( decode(params[:id]), params[:media] )
    if @media.mtype == "Mediatype"
      params[:data][:arguments].map! {|x| x.map {|y| {y[0]=>y[1].capitalize} } } #due to :serialize
    end
    Object.const_get(@media.mtype.pluralize).update_all(params[:data], [ "media_id = ?", decode(params[:id]) ])
    @media.save
    redirect_to edit_media_url
  end

  def new
    @showntype = "editor"
    @action = "create"
#New mediatype => need new folder in /media, new table in dev.sqlite3, (new object on server), and new mediatype record
#Otherwise => Just new media + data records
    @editors = Editors.where("media_id = ?", decode(params[:id]))
    mediatype = Media.find(@editors[0].mtype)
    @media = Media.new(:title => "New " + mediatype.title.downcase, :info => "It's a new " + mediatype.title.downcase + "!", :url => "")
    @data = Object.const_get(mediatype.title.pluralize).new
    @data.arguments = "" if mediatype.title == "Mediatype"
    instance_variable_set( "@" + mediatype.title.downcase, @media )
    render "media/" + params[:id] + "/edit"
  end

  def create
    @media = Media.new(params[:media])
    mediatype = Media.find( Editors.where( "media_id = ?", decode(params[:id]) )[0].mtype )
    @media.mtype = mediatype.title
    @data = Object.const_get(@media.mtype.pluralize).new(params[:data])
    if @media.mtype == "Mediatype"
      basetype = {"array" => "text"}
      args = @data.arguments[0].map {|x| [ x[0], basetype[x[1]] || x[1] ] }
      T.create( @media.title.downcase.pluralize.to_sym, {:media_id => :integer}.merge(@data.arguments[0]) )
      @data.arguments.map! {|x| x.map {|y| {y[0]=>y[1].capitalize} } }.flatten!
      Object.const_set( @media.title.pluralize, Class.new(ActiveRecord::Base) {
        establish_connection(:development)
        belongs_to :media
      } )
      Object.const_set( @media.title, Class.new(ActiveRecord::Base) {
        establish_connection(:development)
      } )
      @data.arguments.each do |x|
        Object.const_get(@media.title).class_eval "serialize :#{x[0]}, Array" if x[1]=="Array"
      end
      Media.class_eval "has_many :#{@media.title.pluralize}"
    end
    @media.save
    @data.media_id = @media.id
    @data.save
    if @media.mtype == "Mediatype"
      path = Rails.root.join("app/views/media", @media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + @media.url
  end

end
