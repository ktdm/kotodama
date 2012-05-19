class MediatypeResolver < ActionView::PathResolver

  include Url

  def query(path, details, formats)
    mediatype = Media.find(decode (path.name.split("/").first)).mediatype
    mediatype.data.views.map { |hash|
      handler, format = extract_handler_and_format(hash.keys[0], formats)

      ActionView::Template.new(hash.values[0], path, handler,
        :virtual_path => path.virtual,
        :format       => format,
        :updated_at   => mediatype.updated_at) #<- for each template?
        #:context => :page ?
    }
  end

end
