module ActionView
  class PartialRenderer < AbstractRenderer
    include Url

    def find_template(path, locals)
      prefixes = path.include?(?/) ? [] : @lookup_context.prefixes
      prefixes = [] if prefixes[0] == "media"
      @lookup_context.find_template(path, prefixes, true, locals, @details)
    end

    def retrieve_variable(path)
      variable = @options[:as].try(:to_sym) || path[%r'_?(\w+)(\.\w+)*$', 1].to_sym #??
      variable_counter = :"#{variable}_counter" if @collection
      [variable, variable_counter]
    end
  end
end

class InspectableMemoryStore < ActiveSupport::Cache::FileStore
  def write *args
    super

    @inspectable_keys[ args[0] ] = true
  end

  def delete *args
    super

    @inspectable_keys.delete args[0]
  end

  def keys
    @inspectable_keys.keys
  end
end

ActionController::Base.cache_store = InspectableMemoryStore.new nil
