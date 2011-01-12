module GettextToI18n
  class GettextI18nConvertor
    
    attr_accessor :text
    
    GETTEXT_VARIABLES = /\%\{(\w+)\}*/
    
    # initializer
    # text, namespace and default type "views" as parameter
    def initialize(text, namespaces, type = 'views')
      @text = text
      @namespaces = namespaces
      @type = type
    end
    
    # The contents of the method call
    def contents
      single_quotes = /\_\(\'([^']*)\'.*\)/.match(@text)
      double_quotes = /\_\(\"([^"]*)\".*\)/.match(@text)
      
      if single_quotes
        return single_quotes[1]
      elsif double_quotes
        return double_quotes[1]
      else
        return nil
      end
    end
    
    def contents_i18n
      c = contents
      unless c.nil?
        c.gsub!(GETTEXT_VARIABLES, '{{\1}}')
        c.gsub!(GETTEXT_VARIABLES, '%{\1}') # new
        c.gsub!(/^(\"|\')/, '')
        c.gsub!(/(\"|\')$/, '')
      else
        puts "No content: " + @text
      end
      c
    end
    
    # returns the part after the method call, 
    # _('aaa' % :a => 'sdf', :b => 'agh') 
    # return :a => 'sdf', :b => 'agh'
    def variable_part
      @variable_part_cached ||= begin
          result = /\%[\s]+\{(.*)\}/.match(@text)
          if result
              result[1]
          end
      end
    end
    
    # extract the variables out of a gettext variable part
    # we cannot simply split the variable part on a comma, because it
    # can contain gettext calls itself.
    # example: :a => 'a', :b => 'b' => [":a => 'a'", ":b => 'b'"]
    def get_variables_splitted
      return if variable_part.nil? 
      in_double_quote = in_single_quote = false
      method_indent = 0  
      s = 0
      vars = []
      variable_part.length.times do |i|
        token = variable_part[i..i]
        in_double_quote = !in_double_quote if token == "\""
        in_single_quote = !in_single_quote if token == "'"
        method_indent += 1 if token == "("
        method_indent -= 1 if token == ")"
        if (token == "," && method_indent == 0 && !in_double_quote && !in_single_quote) || i == variable_part.length - 1
          e = (i == variable_part.length - 1) ? (i ) : i - 1
          vars << variable_part[s..e]
          s = i + 1
        end
      end
      return vars
    end
    
    # return an array of hashes containing the variables used in the
    # gettext call.
    def variables
      @variables_cached ||= begin
        vsplitted = get_variables_splitted
        return nil if vsplitted.nil?
        vsplitted.map! { |v| 
          r = v.match(/\s*:(\w+)\s*=>\s*(.*)/)
          {:name => r[1], :value => GettextI18nConvertor.string_to_i18n(r[2], @namespaces, @type)}
        }
      end
    end
    
    # after analyzing the variable part, the variables
    # it is now time to construct the actual i18n call
    def to_i18n
      id = ''
      @namespaces.each do |ns|
        id = ns.consume_id!(GettextI18nConvertor.create_key(contents_i18n))
        ns.set_id(id, contents_i18n)
      end
      
      # for later on to call with standard t(".key")
      # for lazy lookup in views
      # example: "t.("hello") --> could be in /app/views/articles/index.html.haml
      if @type == 'views'
        output = "t('.#{id}'"
      
      # for later on to call with namespace as part of
      # key, because lazy lookup does not work in controllers
      # models or helpers
      # example: "I18n.t("controllers.controllername.key1")
      else
        output = "I18n.t('#{@namespaces.first.to_i18n_scope + id}'"
      end
      
      if !self.variables.nil?
          vars = self.variables.collect { |h| {:name => h[:name], :value => h[:value] }}
          output += ", " + vars.collect {|h| ":#{h[:name]} => #{h[:value]}"}.join(", ")
      end
      
      output += ")"
      return output
    end
    
    # takes the gettext calls out of a string and converts
    # them to i18n calls
    def self.string_to_i18n(text, namespaces, type)
      s = self.indexes_of(text, /_\(/)
      e = self.indexes_of(text, /\)/)
      
      indent, indent_all,startindex, endinde, methods  = 0, 0, -1, -1, []
      
      output = ""
      level = 0
      gettext_blocks = []
      text.length.times do |i|

        token = text[i..i]
       
        in_gettext_block = gettext_blocks.size % 2 == 1
        if !in_gettext_block
          if ! /_\(/.match(token + text[i+1..i+1]).nil?
            gettext_blocks << i
            level = 0
          end
        else # in a block
          level += 1 if ! /\(/.match(token).nil? && gettext_blocks[gettext_blocks.length - 1] != i - 1
          gettext_blocks << i if level == 0 && /\)/.match(token)
          level -= 1 if /\)/.match(token) && level != 0
        end
      end
      
      i = 0
      output = text.dup
      offset = 0
      
      (gettext_blocks.length / 2).times do |i|
        
        s = gettext_blocks[i * 2]
        e = gettext_blocks[i * 2 + 1]
        to_convert = text[s..e]
       
        converted_block = GettextI18nConvertor.new(to_convert, namespaces, type).to_i18n
        g = output.index(to_convert) - 1
        
        h = g + (e-s) + 2
        output = output[0..g] + converted_block + output[h..output.length]
      end
      output
    end
    
    # create a key name for a new one
    # example content is nil => key = message
    # example content is not nil => key = first_three_words
    def self.create_key(s, max_words = 3)
      s = 'message' if s.nil?
      # all down
      s.downcase!
      
      # max words 
      words = s.split(/\s/) 
      if words.size >= max_words
        s = words[0..(max_words-1)].join("_")
      else
        s = words.join("_")
      end
      
      # preserve alphanumerics, everything else becomes a separator
      s.gsub(/[^a-z0-9_]/, '')
    end
    
    private 
    
    # finds indexes of some pattern(regexp) in a string
    def self.indexes_of(str, pattern)
      indexes = []
      str.length.times do |i|
        match = str.index(pattern, i)
        indexes << match if !indexes.include?(match)
      end
      indexes
    end
    
  end
end