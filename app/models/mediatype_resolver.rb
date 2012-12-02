class MediatypeResolver < ActionView::PathResolver
  def query(path, details, formats)
    mediatype = Media.find(decode (path.prefix.split("/").first)).mediatype
    mediatype.data.views.map { |name, source|
      handler, format = extract_handler_and_format(name, formats)

      Template.new(source, path, handler,
        :virtual_path => path.virtual,
        :format       => format,
        :updated_at   => mediatype.updated_at) #<- for each template?
        #:context => :page ?
    }
  end
end
