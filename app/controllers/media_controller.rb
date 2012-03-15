class MediaController < ApplicationController

  include Url

  def show
    @media = Media.find( decode( params[:id] ) )
    if @media.mtype == "Mediatype"
      instance_variable_set( "@" + @media.title.downcase.pluralize,
                             Media.where( "mtype = ?", @media.title ) )
#self.view_paths << Rails.root.join("app/views/media/" + params[:id])
      render "media/" + params[:id] + "/index"
    elsif @media.mtype == "Editor"
      edit
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    @media = Media.find( decode( params[:id] ) )
    @title = "Edit mediatype '" + @media.title + "' | kotoda.ma"
    Object.const_set( "Editors",
                      Class.new(ActiveRecord::Base) {establish_connection(:development)} )
    type = Media.find( Editors.where( "media_id = ?", @media.id )[0].mtype )
    Media.class_eval "has_many :#{type.title.downcase.pluralize}"
    Object.const_set( type.title.pluralize,
                      Class.new(ActiveRecord::Base) {
      establish_connection(:development)
#:joins?
      belongs_to :media
    } )
    instance_variable_set( "@" + type.title.downcase,
#                           Media.joins( type.title.downcase.pluralize.to_sym ).where( "media_id = ?", 1 )[0] )
                           Object.const_get( type.title.pluralize ).joins( :media ).where( "media_id = ?", 1 )[0] )
render :inline => "'"+@mediatype.signature+"'"
#    render "media/" + params[:id] + "/edit"
  end

end
