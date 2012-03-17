class MediaController < ApplicationController

  include Url

  def show
    @media = Media.find( decode( params[:id] ) )
    if @media.mtype == "Mediatype"
      instance_variable_set( "@" + @media.title.downcase.pluralize,
                             Media.where( "mtype = ?", @media.title ) )
#      self.append_view_path Rails.root.join("app/views/media/" + params[:id])
#render @mediatypes #Calls to ActionResource
#something like..?: Object.const_set( "MediatypeResource", Class.new (ActionResource::Base) { etc } )
      render "media/" + params[:id] + "/index"
    elsif @media.mtype == "Editor"
      edit
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    @media = Media.find( decode( params[:id] ) )
    @title = "Edit mediatype '" + @media.title + "' | kotoda.ma" #edit what? :P
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    if @media.mtype == "Editor" #optimise for redirect (recycle klasses, select where url=old params[:id])
      type = Media.find( Editors.where( "media_id = ?", @media.id )[0].mtype ) #redo as join
      Media.class_eval "has_many :#{type.title.downcase.pluralize}"
      Object.const_set( type.title.pluralize,
                        Class.new(ActiveRecord::Base) {
        establish_connection(:development)
        belongs_to :media
        serialize :signature, Array #generalise??
      } )
#      Mediatype.find(Media.find(old params[:id]).mtype)).forall x w/ (signature in y=[Array,Hash]) do #as join
#        Object.const_get( type.title.pluralize ).class_eval "serialize :#{x}, #{y}"
      instance_variable_set( "@" + type.title.downcase,
                             Media.joins( type.title.downcase.pluralize.to_sym ).where( "media_id = ?", 1 )[0] )
      @data=Object.const_get( type.title.pluralize ).where( "media_id = ?", 1 )[0]
#Object.const_set("MediatypeController",Class.new(MediaController))
#Object.const_get("MediatypeController").new.render "media/" + params[:id] + "/edit"
      render "media/" + params[:id] + "/edit" #mediatype_controller...
    else
      redirect_to root_url + encode( Editors.where( "mtype = ?", @media.id )[0].media_id )
    end
  end

  def update

  end

end
