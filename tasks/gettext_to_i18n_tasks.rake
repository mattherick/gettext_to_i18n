# desc "Explaining what the task does"
# task :gettext_to_i18n do
#   # Task goes here
# end

require File.dirname(__FILE__) + '/../init'

namespace :gettext_to_i18n do
  
  desc 'Transforms all of your files into the new I18n api format'
  task :transform => %w(environment) do # w(environment) for multiple languages because i18n gem needed
    GettextToI18n::Base.new
  end
  
  
end
