require 'test/unit'
require File.dirname(__FILE__) + '/../init.rb'

class FilesTest < Test::Unit::TestCase

  def test_controller_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/controllers', '**/*.rb') + GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/controllers', '**/*.rb')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end

  def test_view_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/views', '**/*.{erb,builder,haml}')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_lib_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/lib', '*.rb')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_helper_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/helpers', '*.rb') + GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/helpers', '**/*.rb')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_model_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/models', '*.rb') + GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/models', '**/*.rb')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_mailer_files
    files = GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/mailers', '*.rb') + GettextToI18n::Files.get_files('vendor/plugins/gettext_to_i18n/test/dummy/app/mailers', '**/*.{erb,haml}')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_get_controller_filename
    assert_equal ["admin", "admin_controller"], GettextToI18n::Base.get_namespace('/controllers/admin/admin_controller.rb', 'controllers')
    assert_equal ['application_controller'], GettextToI18n::Base.get_namespace('/controllers/application_controller.rb', 'controllers')
  end
  
  def test_get_view_filename
    assert_equal ["page", "index"], GettextToI18n::Base.get_namespace('/views/page/index.html.erb', 'views')
    assert_equal ["page", "under", "index"], GettextToI18n::Base.get_namespace('/views/page/under/index.html.erb', 'views')
  end
  
  def test_get_model_filename
    assert_equal ["comment"], GettextToI18n::Base.get_namespace('/models/comment.rb', 'models')
    assert_equal ["admin","comment"], GettextToI18n::Base.get_namespace('/models/admin/comment.rb', 'models')
  end
  
  def test_get_mailer_filename
    assert_equal ['feedback_mailer'], GettextToI18n::Base.get_namespace('/mailers/feedback_mailer.rb', 'mailers')
    assert_equal ['notification_mailer','new_answer'], GettextToI18n::Base.get_namespace('/mailers/notification_mailer/new_answer.erb', 'mailers')
    assert_equal ['notification_mailer','new_answer'], GettextToI18n::Base.get_namespace('/mailers/notification_mailer/new_answer.haml', 'mailers')
  end
  
  def test_get_helper_filename
    assert_equal ["blogs"], GettextToI18n::Base.get_namespace('/helpers/blogs_helper.rb', 'helpers')
    assert_equal ["api","blogs"], GettextToI18n::Base.get_namespace('/helpers/api/blogs_helper.rb', 'helpers')
  end
  
  def test_get_lib_filename
    assert_equal ["cap_mailer"], GettextToI18n::Base.get_namespace('/lib/cap_mailer.rb', 'lib')
  end
end