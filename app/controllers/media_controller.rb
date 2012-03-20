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
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    if params[:context].nil? #find editor
      ers = Editors.where( "mtype = ?", @media.id )
      ers.length > 0 ? redirect_to(root_url + encode( ers[0].media_id ) + "/" + params[:id])
                     : new #this will become "Edit new editor"
    else
      ers = Editors.where( "mtype = ?", decode(params[:id]) )
      if ers.length == 1 #edit instance with its editor
#        redirect_to(root_url + params[:context]) if ers[0].mtype != decode(params[:context])
        type = Media.find( ers[0].mtype ) #redo as join
        Media.class_eval "has_many :#{type.title.downcase.pluralize}"
        Object.const_set( type.title,
                          Class.new(ActiveRecord::Base) {
          establish_connection(:development)
          belongs_to :media
          serialize :signature, Array #generalise??
        } )
        Object.const_set( type.title.pluralize, Class.new( Object.const_get(type.title) ) )
#        Mediatype.find(Media.find(old params[:id]).mtype)).forall x w/ (signature in y=[Array,Hash]) do #as join
#          Object.const_get( type.title.pluralize ).class_eval "serialize :#{x}, #{y}"
        instance_variable_set( "@" + type.title.downcase,
                               Media.joins( type.title.downcase.pluralize.to_sym ).where( "media_id = ?", 1 )[0] )
        @title = "Edit mediatype '" + type.title + "' | kotoda.ma" #title should really be a in root_url/b/*a*
        @data = Object.const_get( type.title.pluralize ).where( "media_id = ?", 1 )[0]
        @script = Class.new {attr_accessor :value}.new
        @script.value = IO.read(Rails.root.join("app/views/media", params[:id], "index.html.erb"))
        render "media/" + params[:context] + "/edit" #will mongo save my api??
      elsif ers.length > 1 #more than one editor
        render :inline => "duplicate id issue :("
      else #incorrect editor reference
        redirect_to root_url + params[:id] + "/edit"
      end
    end
  end

  def new
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    mtype = Editors.where("media_id = ?", decode(params[:id]))[0].mtype
    render :inline => "Edit new " + Media.where("id = ?", mtype)[0].title
  end

  def update

  end

  def create #activerecord creation to be moved here!

  end

end
