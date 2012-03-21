class MediaController < ApplicationController

  include Url

  def show
    if params[:context].nil?
      @media = Media.find( decode( params[:id] ) )
      instance_variable_set( "@" + @media.title.downcase.pluralize,
                             Media.where( "mtype = ?", @media.title ) )
#      self.append_view_path Rails.root.join("app/views/media/" + params[:id])
#render @mediatypes #Calls to ActionResource
#something like..?: Object.const_set( "MediatypeResource", Class.new (ActionResource::Base) { etc } )
      @media.mtype == "Editor" ? new : render("media/" + params[:id] + "/index")
    else
      @media = Media.find ( decode( params[:context] ) )
      @media.mtype == "Editor" ? edit : render("media/" + params[:context] + "/index")
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    @media = Media.find( decode( params[:id] ) ) #find instance
    Object.const_set( "Mediatypes",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    @mediatype = Mediatypes.where("media_id = ?", Media.where("title = ?", @media.mtype)[0].id)[0]
    @editors = Editors.where( "mtype = ?", @mediatype.media_id )
    @editor_url = root_url + encode( @editors[0].media_id ) #add helper
    if params[:context].nil? #find editor
      @editors.length > 0 ? redirect_to(@editor_url + "/" + params[:id])
                          : new #this will become "Edit new editor"
    elsif @editors.length == 1 #edit instance with its editor
#      redirect_to(root_url + params[:context]) if @editors[0].mtype != decode(params[:context])
      type = Media.find( @editors[0].mtype ) #redo as join
      Media.class_eval "has_many :#{type.title.downcase.pluralize}"
      Object.const_set( type.title,
                        Class.new(ActiveRecord::Base) {
        establish_connection(:development)
        belongs_to :media
        serialize :arguments, Array #generalise??
      } )
      Object.const_set( type.title.pluralize, Class.new( Object.const_get(type.title) ) )
#      Mediatype.find(Media.find(old params[:id]).mtype)).forall x w/ (arguments in y=[Array,Hash]) do #as join
#        Object.const_get( type.title.pluralize ).class_eval "serialize :#{x}, #{y}"
      instance_variable_set( "@" + type.title.downcase,
                             Media.joins( type.title.downcase.pluralize.to_sym ).where( "media_id = ?", @media.id )[0] )
      @title = "Edit mediatype '" + type.title + "' | kotoda.ma" #title should really be a in root_url/b/*a*
      @data = Object.const_get( type.title.pluralize ).where( "media_id = ?", @media.id )[0]
      @script = Class.new {attr_accessor :value}.new
      @script.value = IO.read(Rails.root.join("app/views/media", params[:id], "index.html.erb"))
      render "media/" + params[:context] + "/edit" #will mongo save my api??
    elsif @editors.length > 1 #more than one editor
      render :inline => "duplicate id issue :("
    else #incorrect editor reference
      redirect_to root_url + params[:id] + "/edit"
    end
  end

  def update
    @media = Media.update( decode(params[:id]), params[:media] )
    @mediatype = Mediatypes.where("media_id = ?", Media.where("title = ?", @media.mtype)[0].id)[0] #Media.mtype change to mediatype_id
    @data = Object.const_get(@media.mtype.pluralize).update(@mediatype.id, params[:data] )
    @data.arguments.map! {|x| x.map {|y| {y[0]=>y[1].capitalize} } }.flatten! #For the editor?
    @media.save
    @data.save
    File.open(Rails.root.join("app/views/media", params[:id], "index.html.erb").to_s, "w") {|f| f.write(params[:script][:value]) }
    redirect_to edit_media_url
  end

  def new
    @showntype = "editor"
    @action = "create"
#New mediatype => need new folder in /media, new table in dev.sqlite3, (new object on server), and new mediatype record
#Otherwise => Just new media + data records
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    @editors = Editors.where("media_id = ?", decode(params[:id]))
    mediatype = Media.find(@editors[0].mtype)
    @media = Media.new(:title => "New " + mediatype.title.downcase, :info => "It's a new " + mediatype.title.downcase + "!")
    @data = Object.const_get(mediatype.mtype.pluralize).new
    @mediatype = @media
    render "media/" + params[:id] + "/edit"
  end

  def create
    @media = Media.new(params[:media])
    mediatype = Media.find( Editors.where( "media_id = ?", decode(params[:id]) )[0].mtype )
    @media.mtype = mediatype.title
    @data = Object.const_get(@media.mtype.pluralize).new(params[:data])
    @data.arguments.map! {|x| x.map {|y| {y[0]=>y[1].capitalize} } }.flatten! #Ditto
    @script = Class.new {attr_accessor :value}.new
    @script.value = params[:script][:value]
    @media.save
    @data.media_id = @media.id
    @data.save
    File.open(Rails.root.join("app/views/media", @media.url, "index.html.erb").to_s, "w") {|f| f.write(@script.value) }
    redirect_to media_url + "/" + @media.url
  end

end
