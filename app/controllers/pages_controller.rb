class PagesController < ApplicationController

  def new
    @showntype = "editor"
    @page = Page.new(:id => Page.count + 1, :title => "New page", :info => "It's a new page!", :html => "<h1 style='text-align:center'>My new page</h1>")
    @title = "Edit new page | kotoda.ma"
    @action = "create"
    render "edit"
  end

  def edit
    @showntype = "editor"
    @page = Page.find(params[:id])
    @title = "Edit page '" + @page.title + "' | kotoda.ma"
    @action = "update"
  end

  def index
    @pages = Page.order("views DESC,created_at DESC") || {}
    @showntype = "mediatype"
    @title = "Show all pages | kotoda.ma"
    respond_to do |format|
      format.html
      format.json {render :json => @pages}
    end
  end

  def create
    @page = Page.new(params[:page])
    @page.title.capitalize!
    @page.save
    redirect_to edit_page_url
  end

  def update
    @page = Page.update(params[:id],params[:page])
    @page.title.capitalize!
    @page.save
    redirect_to edit_page_url
  end

  def show
    @page = Page.find(params[:id])
    @page.views+=1
    @page.save
    render :inline => @page.html
  end

  def talk
    @page = Page.find(params[:id])
    @title=@@title
  end

end
