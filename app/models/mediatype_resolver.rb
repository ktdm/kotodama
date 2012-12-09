class MediatypeResolver < ActionView::PathResolver

  #views["x"] is for converting media to x format
  #views["x:y"] is an included file of mediatype x - may be for internal use only

  include Url

  def find_templates(name, prefix, partial, details)
    name = name.sub(/\A(?:.+:)?(.+)\.(.+)\Z/, '\2:\1') unless name.index(".").nil?
    mediatype, name = name.index(":").nil? ? ["", name] : name.split(":")
    if partial or mediatype.downcase == "partial"
      partial = true
      mediatype = "partial"
    end
    path = MediaPath.build(name, prefix, partial, mediatype.empty? ? details[:formats] : [mediatype.to_sym])
    query(path, details, path.formats )
  end

  def query(path, details, formats)
    p = path.split("/")
    mediatype = p[-1].index(":").nil? ?
      Media.find( decode p[0].sub(/^.+:/,"") ).mediatype :
      Media.find( decode p[0].sub(/^.+:/,"") )
    name = ( [formats.first] + [p[-1].sub(/^.+:/,"")].reject {|y| p[-1].index(":").nil? or p[-1].split(":")[-1] == p[0].split(":")[-1] } ) * ":"
    mediatype.data.views.select { |x| x.keys[0] == name }.map { |hash|
      ActionView::Template.new(hash.values[0], path, ActionView::Template::Handlers::ERB,
        :virtual_path => path.virtual,
        :format       => formats.first, #???
        :updated_at   => mediatype.updated_at) #<- for each template?
    }
  end

end
