module ActionView
  class PartialRenderer < AbstractRenderer
    include Url

    def find_template(path, locals)
puts "|" + path + "|"
      prefixes = path.include?(?/) ? [] : @lookup_context.prefixes
      prefixes = [] if prefixes[0] == "media"
      @lookup_context.find_template(path, prefixes, true, locals, @details)
    end

    def retrieve_variable(path)
      variable = @options[:as].try(:to_sym) || path[%r'_?(\w+)(\.\w+)*$', 1].to_sym
puts path[%r'(\w*):?(\w+)', 2].to_s + " - " + variable.to_s #this
#Media.find(decode path).data_type.to_s
      variable_counter = :"#{variable}_counter" if @collection
      [variable, variable_counter]
    end
  end
end
