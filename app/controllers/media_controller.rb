class MediaController < ApplicationController

  require "active_support/core_ext/kernel/singleton_class.rb"

  include Url

  def show
x = params[:id]
    @media = Media.find( decode( params[:id] ) )
    if @media.mtype == "Mediatype"
      instance_variable_set( "@" + @media.title.downcase.pluralize,
                             Media.where( "mtype = ?", @media.title ) )
      self.class_eval do
        def path x
          append_view_path Rails.root.join("app/views/media/" + x)
        end
      end
      path x
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
render :inline => '<%= link_to image_tag("kotodama_logo_black.jpg", :id => "logo", :alt => "kotoda.ma", :title => "kotoda.ma"), root_url %>'
#    render "media/" + params[:id] + "/edit"
  end

end
