module GettextToI18n
  class Namespace
    attr_reader :ids
    attr_reader :locale
    
    def initialize(name,locale)
      @ids = {}
      @namespace = name
      @locale = locale
    end
    
    # reserves a id
    def consume_id!(key,id = nil)
      id = "msg#{@ids.length.to_s}_#{key}" if id.nil?
      raise "ID already in use" if @ids.keys.include?(id)
      @ids[id] = ""
      return id
    end
    
    def set_id(id, value)
      @ids[id] =  I18n.t(value, :default => value.to_s, :locale => @locale)
    end
    
    def to_s
      o = "Namespace: {" + @namespace
      o <<  @ids.to_yaml
      o << "}"
    end
    
    def i18n_namespace
      @cached_i18n_namespace ||= begin
        a = @namespace.dup
        a.delete(@locale)
        a
      end
    end
    
    def to_i18n_scope
      @cached_i18n_scope ||= i18n_namespace.collect {|x| "#{x}."}.join("")
    end
    
    # merges new translations with old yaml file
    def merge(base)
      @namespace.each do |key|  
        base[key] ||= {}
        base = base[key]
      end
      base.merge!(@ids)
    end

  end
end