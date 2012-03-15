class MediatypesController < ApplicationController

  def index
    @showntype = "mediatype"
    @title = "Show all mediatypes | kotoda.ma"
    @mediatypes = Mediatype.order("instances DESC,created_at DESC") || {}
  end

  def new
    @showntype = "editor"
    @mediatype = Mediatype.new(:id => Mediatype.count + 1, :title => "New mediatype", :info => "It's a new mediatype!", :script => "<h1 style='text-align:center'>My new mediatype</h1>")
    @title = "Edit new mediatype | kotoda.ma"
    @action = "create"
    render "edit"
  end

  def edit
    @showntype = "editor"
    @mediatype = Mediatype.find(params[:id])
    @title = "Edit mediatype '" + @mediatype.title + "' | kotoda.ma"
    @action = "update"
  end

  def create
    @mediatype = Mediatype.new(params[:mediatype])
    @mediatype.title.capitalize!
    @mediatype.save
    redirect_to edit_mediatype_url
  end

  def update
    @mediatype = Mediatype.update(params[:id],params[:mediatype])
    @mediatype.title.capitalize!
    @mediatype.signature = params[:mediatype][:signature]
    @mediatype.signature.map!{|x| {x.keys[0]=>x.values[0].capitalize} } if @mediatype.signature
    @mediatype.save
    redirect_to edit_mediatype_url
  end

  def show
    @mediatype = Mediatype.find(params[:id])
    locals = (@mediatype.signature) ? Hash[@mediatype.signature.map!{|x| [x.keys[0].to_sym,x.values[0]] }] : {}
    render :inline => @mediatype.script, :locals => {@mediatype.title.downcase.to_sym => locals}
  end

end
