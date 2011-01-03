module GettextToI18n
  
  class Base
    LOCALE_DIR = RAILS_ROOT + '/config/locales/'
    
    LANGUAGES = ['en','de']
    
    TYPES = ['controllers','models','helpers','views','mailers','lib']

    def initialize
      TYPES.each do |type|
        transform_files!(Files.type_files(type), type)
      end
    end
    
    # Walks all files and converts them all to the new format
    def transform_files!(files, type)  
      files.each do |file|
        @file = file
        @type = type
        parsed = ""
        @dirnames =  Base.get_namespace(file,type) # directories after the app/type/ directory
        
        namespaces = LANGUAGES.collect do |lang|
          if type == 'views'
            namespace = [lang] + @dirnames
          else
            namespace = [lang, type] + @dirnames
          end
        
          puts "Converting: " + file + " into namespace: "
          puts namespace.map {|x| "[\"#{x}\"]"}.join("")
        
          Namespace.new(namespace,lang)
        end

        contents = Base.get_file_as_string(file)
        parsed << GettextI18nConvertor.string_to_i18n(contents, namespaces, type)
        
        # write the app/type/file with new i18n format instead of gettext
        File.open(file, 'w') { |file| file.write(parsed)}
        
        namespaces.each do |ns|
          new_file_handler(ns)
        end
      end
    end
    
    def new_file_handler(ns)
      @yaml, @yaml2 = {}
      
      # load old files if they exist
      filepath = create_filepath(ns.locale)
      @yaml = YAML.load_file(filepath) if File.exists?(filepath) 

      # new translations (ns) merges with existing file or with an empty hash
      ns.merge(@yaml)
      cleanup!(@yaml)

      dump_yaml!(filepath,@yaml)  
    end
    
    def create_filepath(language)
      # directory will be created in config/locales/type/ in dump_yaml!
      @dirpath = File.join(LOCALE_DIR + @type + '/' + @dirnames.first)
      File.join(@dirpath + '/' + language + '.yml')
    end
 
    # Dumps the translation strings into yml files
    def dump_yaml!(filepath,translations)
      return if translations.blank?
      FileUtils.mkdir_p(@dirpath) unless File.exists?(@dirpath)
      File.open(filepath, 'w+') { |f| YAML::dump(translations, f) } 
    end
    
    def cleanup!(content)
      content.each do |key, value|  
        cleanup!(value) if value.is_a? Hash
        content.delete(key) if value.blank?
      end
    end 
    
    private 
    def self.get_file_as_string(filename)
      data = ''
      f = File.open(filename, "r") 
      f.each_line do |line|
        data += line
      end
      return data
    end
    
    # returns a name for a file
    # example: Base.get_name('/controllers/apidoc_controller.rb', 'controller') => 'apidoc'
    def self.get_namespace(file,type)
      case type
        when 'controllers'
          result = /controllers\/?([\_a-zA-Z0-9]+)?\/([\_a-zA-Z0-9]+).rb/.match(file)
          if result[1].nil?
            return [result[2]]
          else
            return [result[1],result[2]]
          end
        when 'helpers'
          result = /helpers\/?([\_a-zA-Z0-9]+)?\/([\_a-zA-Z0-9]+)_helper.rb/.match(file)
          if result[1].nil?
            return [result[2]]
          else
            return [result[1],result[2]]
          end
        when 'models'
          result = /models\/?([\_a-zA-Z0-9]+)?\/([\_a-zA-Z0-9]+).rb/.match(file)
          if result[1].nil?
            return [result[2]]
          else
            return [result[1],result[2]]
          end
        when 'views'
          result = /views\/([\_a-zA-Z0-9]+)\/?([\_a-zA-Z0-9]+)?\/([\_a-zA-Z0-9]+).*\.([a-zA-Z0-9]+)/.match(file)
          
          temp = result[3]
          # if partial remove the first underscore
          temp.slice!(0) if temp.first == '_'

          if result[2].nil?
            if result[4] != "erb" && result[4] != "haml"
              return [result[1], temp, result[4]]
            else
              return [result[1], temp] 
            end
          else
            if result[4] != "erb" && result[4] != "haml"
              return [result[1], result[2], temp, result[4]]
            else
              return [result[1], result[2], temp] 
            end
          end
        when 'mailers'
          result = /mailers\/?([\_a-zA-Z0-9]+)?\/([\_a-zA-Z0-9]+)\.([a-zA-Z0-9]+)/.match(file)

          if result[1].nil?
            if result[3] != "erb" && result[3] != "haml" && result[3] != "rb"
              return [result[2], result[3]]
            else
              return [result[2]] 
            end
          else
            if result[3] != "erb" && result[3] != "haml" && result[3] != "rb"
              return [result[1], result[2], result[3]]
            else
              return [result[1], result[2]] 
            end
          end  
        when 'lib'
          result = /([\_a-zA-Z0-9]+).rb/.match(file)
          return [result[1]]
        
      end
    end   
  end
end