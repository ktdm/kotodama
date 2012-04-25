class MediaController < ApplicationController

  include Url
  include AddTables
  include InitMedia

  def show
    if params[:context].nil?
      media = Media.find( decode params[:id] )
      init_obj(media.mdata_type) unless Object.const_defined? media.mdata_type
      @media = Object.const_get(media.mdata_type).find(media.mdata_id)
      instance_variable_set("@" + @media.media[0].title.downcase.pluralize, Object.const_get(media.mdata_type).all) if ["Mediatype","Editor"].index(media.mdata_type) #.send?
      instance_variable_set( "@" + media.mdata_type.downcase, @media.media[0] )
      case media.mdata_type
      when "Editor"
        new
      when "Mediatype"
        render :inline => Mediatype.find(1).script, :layout => "application"
      else
        render :inline => Mediatype.where(:title => media.mdata_type)[0].script
      end
    else
      media = Media.find ( decode params[:context] )
      media.mdata_type == "Editor" ? edit : render("media/" + params[:context] + "/index")
    end
  end

  def edit
    @showntype = "editor"
    @action = "update"
    @media = Media.find( decode params[:id] ) #find instance
    init_obj(@media.mtype) unless Object.const_defined? @media.mtype.pluralize
    @mtype = Mediatypes.where( :media_id => Media.where(:title => @media.mtype)[0].id)[0] #FIXME define mediatypes as extensions of the media model
#    @mtype = Media.where("title = ?", @media.mtype)[0].mediatypes[0]
    @editors = Editors.where( :mtype => @mtype.media_id )
    @editor_url = root_url + encode( @editors[0].media_id ) #add helper
    if params[:context].nil? #find editor
      @editors.length > 0 ? redirect_to(@editor_url + "/" + params[:id])
                          : new #this will become "Edit new editor" once 'create Editor' is working
    elsif @editors.length == 1 #edit instance with its editor
#      redirect_to(root_url + params[:context]) if @editors[0].mtype != decode(params[:context])
      instance_variable_set( "@" + @media.mtype.downcase,
                             Media.joins(@media.mtype.downcase.pluralize.to_sym).where(:id => @media.id)[0] )
      @data = Object.const_get( @media.mtype.pluralize ).where( :media_id => @media.id )[0]
      @mtype.arguments[0].each do |w| # generalise for argument types?
        @data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
      end
      render "media/" + params[:context] + "/edit" #will mongo save my api??
    elsif @editors.length > 1 #more than one editor
      render :inline => "duplicate id issue :("
    else #incorrect editor reference
      redirect_to root_url + params[:id] + "/edit"
    end
  end

  def update
    @media = Media.update( decode params[:id], params[:media] )
    @mtype = Mediatypes.where(:media_id => Media.where(:title => @media.mtype)[0].id)[0]
    @mtype.arguments[0].each do |w|
      params[:data][w[0].to_sym].map! {|x| x.map {|y| {y[0]=>y[1]} } } if w[1]=="Array"
    end
    Object.const_get(@media.mtype.pluralize).update_all(params[:data], [ "media_id = ?", decode(params[:id]) ])
    @media.save
    redirect_to edit_media_url
  end

  def new
    @showntype = "editor"
    @action = "create"
    @mtype = Media.joins( :mediatypes ).where( :id => Editors.where( :media_id => decode(params[:id]) )[0].mtype )[0]
    @media = Media.new(:title => "New " + @mtype.title.downcase, :info => "It's a new " + @mtype.title.downcase + "!", :url => "")
    @data = Object.const_get(@mtype.title.pluralize).new
    @data.arguments = "" if @mtype.title == "Mediatype"
    instance_variable_set( "@" + @mtype.title.downcase, @media )
    render "media/" + params[:id] + "/edit"
  end

  def create
    @media = Media.new(params[:media])
    @mtype = Media.find( Editors.where( :media_id => decode(params[:id]) )[0].mtype )
    @media.mtype = @mtype.title
    @data = Object.const_get(@media.mtype.pluralize).new(params[:data])
    if @media.mtype == "Mediatype" # move to mediatype editor?
      basetype = {"Array" => "Text"}
      args = @data.arguments[0].map {|x| [ x[0], basetype[x[1]] || x[1] ] }
      T.create( @media.title.downcase.pluralize.to_sym, {:media_id => :integer}.merge(@data.arguments[0]) )
    end
    @mtype.count += 1
    @mtype.save
    Mediatypes.where("media_id = ?", @mtype.id)[0].arguments[0].each do |w|
      @data.send(w[0]).map! {|x| x.map {|y| {y[0]=>y[1]} } }.flatten! if w[1]=="Array"
    end
    @media.save
    @data.media_id = @media.id
    @data.save
    init_obj(@media.title) if @media.mtype == "Mediatype"
    if @media.mtype == "Editor"
      path = Rails.root.join("app/views/media", @media.url)
      Dir.mkdir(path) unless File.exists?(path)
    end
    redirect_to media_url + "/" + @media.url
  end

end
