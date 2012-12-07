class MediatypeResolver < ActionView::PathResolver

  #views["x"] is for converting media to x format
  #views["x:y"] is an included file of mediatype x - may be for internal use only

  include Url

  def find_templates(name, prefix, partial, details)
    mediatype, name = name.index(":").nil? ? ["", name] : name.split(":")
#puts "path: " + prefix + " -:- " + mediatype.to_s + " <> " + name
    path = Path.build(name, prefix, partial || mediatype.downcase == "partial")
    details[:formats] = [mediatype.to_sym] unless mediatype.empty?
    query(path, details, details[:formats])
  end

  def query(path, details, formats)
puts "path:" + path.prefix + " -~- " + details[:formats].to_s + " <> " + path.name
    mediatype = Media.find(decode (path.prefix.empty? ? path.name : path.prefix)).mediatype #here
    mediatype.data.views.reject {|x| formats.index(x.keys[0].downcase.to_sym).nil? }.map { |hash|
      ActionView::Template.new(hash.values[0], path, ActionView::Template::Handlers::ERB,
        :virtual_path => path.virtual,
        :format       => formats.first, #???
        :updated_at   => mediatype.updated_at) #<- for each template?
    }
  end

end
