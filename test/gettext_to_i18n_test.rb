require 'test/unit'
require File.dirname(__FILE__) + '/../init.rb'
require 'YAML'

class GettextToI18nTest < Test::Unit::TestCase
  def test_all_files
    files = GettextToI18n::Files.all_files
    assert_not_nil files, "no files available"
    assert files.size > 0
   end

  def test_controller_files
    files = GettextToI18n::Files.controller_files
    assert_not_nil files, "no files available"
    assert files.size > 0
    files = GettextToI18n::Files.type_files('controllers')
    assert_not_nil files, "no files available"
    assert files.size > 0
  end

  def test_view_files
    files = GettextToI18n::Files.view_files
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_helper_files
    files = GettextToI18n::Files.helper_files
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_lib_files
    files = GettextToI18n::Files.lib_files
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
  
  def test_mailer_files
    files = GettextToI18n::Files.mailer_files
    assert_not_nil files, "no files available"
    assert files.size > 0
  end
    
  def test_get_filename
    assert_equal ["admin", "admin"], GettextToI18n::Base.get_namespace('/controllers/admin/admin_controller.rb', 'controllers')
    assert_equal ['application'], GettextToI18n::Base.get_namespace('/controllers/application_controller.rb', 'controllers')
    assert_equal ["page", "index"], GettextToI18n::Base.get_namespace('/views/page/index.html.erb', 'views')
    assert_equal ["page", "under", "index"], GettextToI18n::Base.get_namespace('/views/page/under/index.html.erb', 'views')
    assert_equal ["comment"], GettextToI18n::Base.get_namespace('/models/comment.rb', 'models')
    assert_equal ["admin","comment"], GettextToI18n::Base.get_namespace('/models/admin/comment.rb', 'models')
    assert_equal ['feedback_mailer'], GettextToI18n::Base.get_namespace('/mailers/feedback_mailer.rb', 'mailers')
    assert_equal ['notification_mailer','new_answer'], GettextToI18n::Base.get_namespace('/mailers/notification_mailer/new_answer.erb', 'mailers')
    assert_equal ['notification_mailer','new_answer'], GettextToI18n::Base.get_namespace('/mailers/notification_mailer/new_answer.haml', 'mailers')
    assert_equal ["blogs"], GettextToI18n::Base.get_namespace('/helpers/blogs_helper.rb', 'helpers')
    assert_equal ["api","blogs"], GettextToI18n::Base.get_namespace('/helpers/api/blogs_helper.rb', 'helpers')
    assert_equal ["cap_mailer"], GettextToI18n::Base.get_namespace('/lib/cap_mailer.rb', 'lib')
  end
end