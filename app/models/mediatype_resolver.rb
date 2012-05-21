class MediatypeResolver < ActionView::PathResolver

  #Views are titled by :format - eg "html.erb"? "_"? is there an 'embedded html'/'document fragment' filetype?
  # - what about partial images? filetype subdomains? need a general marking system
  #    html.part? and html.blog?

  include Url

  def query(path, details, formats)
    mediatype = Media.find(decode (path.prefix.empty? ? path.name : path.prefix)).mediatype
    mediatype.data.views.select {|x| x.keys[0].downcase == mediatype.title.downcase }.map { |hash|
      ActionView::Template.new(hash.values[0], path, ActionView::Template::Handlers::ERB,
        :virtual_path => path.virtual,
        :format       => :html, # ???
        :updated_at   => mediatype.updated_at) #<- for each template?
    }
  end

end
