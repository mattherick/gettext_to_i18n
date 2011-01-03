# GettextToI18n
module GettextToI18n
  class Files
    
    # all files that contain some gettext methods
    def self.all_files
      self.controller_files + self.view_files + self.helper_files + self.model_files + self.mailer_files + self.lib_files
    end
    
    # All files with specific type
    def self.type_files(type)
      case type
        when 'controllers'
          return self.controller_files
        when 'helpers'
          return self.helper_files
        when 'models'
          return self.model_files
        when 'views'
          return self.view_files
        when 'mailers'
          return self.mailer_files
        when 'lib'
          return self.lib_files
      end
    end
    
    # All controller files
    def self.controller_files
      self.get_files('app/controllers', '*.rb') + self.get_files('app/controllers', '**/*.rb')
    end
    
    # All view files
    def self.view_files
      self.get_files('app/views', '**/*.{erb,builder,haml}')
    end
    
    # All lib files
    def self.lib_files
      self.get_files('lib', '*.rb')
    end
    
    # All helper files
    def self.helper_files
      self.get_files('app/helpers', '*.rb') + self.get_files('app/helpers', '**/*.rb')
    end
    
    # All model files
    def self.model_files
      self.get_files('app/models', '*.rb') + self.get_files('app/models', '**/*.rb')
    end
    
    # All mailer files
    def self.mailer_files
      self.get_files('app/mailers', '*.rb') + self.get_files('app/mailers', '**/*.{erb,haml}')
    end    
    
    private   
    def self.chdir
      Dir.chdir(RAILS_ROOT)
    end

    # All files we need to walk
    def self.get_files(filter = '**', types='*.{erb,rb,haml}')
      self.chdir
      Dir.glob("#{filter}/#{types}")
    end
  end
end