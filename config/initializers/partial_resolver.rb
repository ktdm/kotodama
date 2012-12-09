module ActionView
  class Resolver

    class MediaPath < String
      attr_reader :name, :prefix, :partial, :formats, :virtual
      alias_method :partial?, :partial

      def self.build(name, prefix, partial, formats)
        virtual = ""
        virtual << "#{prefix}/" unless prefix.empty?
        virtual << (formats[0] == :html ? name : "#{formats[0].to_s}:#{name}")
        new name, prefix, partial, formats, virtual
      end

      def initialize(name, prefix, partial, formats, virtual)
        @name, @prefix, @partial, @formats = name, prefix, partial, partial ? [:partial] : formats
        super(virtual)
      end
    end

    def build_path(name, prefix, partial, formats)
      MediaPath.build(name, prefix, partial, formats)
    end

    def decorate(templates, path_info, details, locals)
      cached = nil
      templates.each do |t|
        t.locals         = locals
        t.formats        = details[:formats] || [:html] if t.formats.empty?
        t.virtual_path ||= (cached ||= build_path(*path_info, t.formats))
      end
    end

  end
end
