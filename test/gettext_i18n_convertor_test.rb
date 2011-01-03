require 'test/unit'
require File.dirname(__FILE__) + '/../init.rb'
require 'YAML'
require 'i18n'

module GettextToI18n
  class GettextI18nTest < Test::Unit::TestCase
    
    def test_other_string
      assert_equal 'a   ', GettextI18nConvertor.new("_('a   ')", []).contents
      assert_equal 'a   ', GettextI18nConvertor.new("_('a   ' % {:a => 'sdasd'})", []).contents
      assert_equal 'a   ', GettextI18nConvertor.new("_('a   ') % {:a => 'sdasd'}", []).contents
      assert_equal ":a => 'sdasd'", GettextI18nConvertor.new("_('a   ' % {:a => 'sdasd'})", []).variable_part
    end
  
    def test_views_variables
      assert_equal ":a => 'sdasd', :b => 'sdasd'", GettextI18nConvertor.new("_('a   ' % {:a => 'sdasd', :b => 'sdasd'})", []).variable_part
      assert_equal [{:name => "a", :value => "'sdasd'"}, {:name => "b", :value => "'sdasd'"}], GettextI18nConvertor.new("_('a   ' % {:a => 'sdasd', :b => 'sdasd'})", []).variables
      assert_equal "t('.msg0_new_translation', :a => 'sdasd')", GettextI18nConvertor.new("_('new translation' % {:a => 'sdasd'})", [ Namespace.new("somenamespace", 'en') ]).to_i18n
      assert_equal "t('.msg0_new_translation', :a => 'sdasd', :b => 'sd')", GettextI18nConvertor.new("_('new translation' % {:a => 'sdasd', :b => 'sd'})", [ Namespace.new("somenamespace", "en") ]).to_i18n
      assert_equal ":a => 'sdf' + _(sdf)", GettextI18nConvertor.new("_('aaa' % {:a => 'sdf' + _(sdf)}) %>", [ Namespace.new("somenamespace", "en") ]).variable_part
    end
    
    def test_views_multiple_variables
      assert_equal "<%=t('.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new("somenamespace", 'en') ], 'views') 
    end
    
    def test_multiple_variables
      assert_equal "<%=I18n.t('controllers.somenamespace.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new(["en","controllers","somenamespace"], 'en') ], 'controllers') 
      assert_equal "<%=I18n.t('models.somenamespace.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new(["en","models","somenamespace"], 'en') ], 'models') 
      assert_equal "<%=I18n.t('helpers.somenamespace.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new(["en","helpers","somenamespace"], 'en') ], 'helpers') 
      assert_equal "<%=I18n.t('mailers.somenamespace.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new(["en","mailers","somenamespace"], 'en') ], 'mailers') 
      assert_equal "<%=I18n.t('lib.somenamespace.msg0_new_trans', :a => 'sdf', :b => 'agh') %>", GettextI18nConvertor.string_to_i18n("<%=_('new trans' % {:a => 'sdf', :b => 'agh'}) %>", [ Namespace.new(["en","lib","somenamespace"], 'en') ], 'lib') 
    end

    def test_create_key
      assert_equal 'onewrd', GettextI18nConvertor.create_key('ONEwörd')
      assert_equal 'first_level', GettextI18nConvertor.create_key('first level')
      assert_equal 'one_two_three', GettextI18nConvertor.create_key('one two three')
      assert_equal 'message', GettextI18nConvertor.create_key(blubb = nil)
      assert_equal 'a', GettextI18nConvertor.create_key('"A"')
      assert_equal 'eins_fnf_drei_vier', GettextI18nConvertor.create_key('eins fünf drei vier zwei sechs',4)
    end
    
    def test_views_recursive_gettext
      t = GettextI18nConvertor.new("<%=_('first level' % {:a => 'sdf' + _('second level') + _('second second level'), :b => '21'}) %>", [ Namespace.new("somenamespace", "en") ], 'views')
      assert_equal ":a => 'sdf' + _('second level') + _('second second level'), :b => '21'", t.variable_part
      assert_equal [{:value=>"'sdf' + t('.msg0_second_level') + t('.msg1_second_second_level')", :name=>"a"},  {:value=>"'21'", :name=>"b"}], t.variables
      
      expected = "<%=t('.msg0_first_level', :a => 'sdf' + t('.msg1_second_level') + t('.msg2_second_second_level')) %>"
      actual = GettextI18nConvertor.string_to_i18n("<%=_('first level' % {:a => 'sdf' + _('second level') + _('second second level')}) %>", [ Namespace.new("somenamespace", "en") ], 'views') 
      assert_equal expected, actual 
    end
    
    def test_conroller_recursive_gettext
      expected = "<%=I18n.t('controllers.somenamespace.msg0_first_level', :a => 'sdf' + I18n.t('controllers.somenamespace.msg1_second_level') + I18n.t('controllers.somenamespace.msg2_second_second_level')) %>"
      actual = GettextI18nConvertor.string_to_i18n("<%=_('first level' % {:a => 'sdf' + _('second level') + _('second second level')}) %>", [ Namespace.new(["de","controllers","somenamespace"], "de") ], 'controllers') 
      assert_equal expected, actual 
    end
    
    
    def test_views_variable_parts
      assert_equal "t('.msg0_a', :a => 'sdasddd', :b => 'sdasd' + t('.msg1_sfd'))" , GettextI18nConvertor.new("_('a   ' % {:a => 'sdasddd', :b => 'sdasd' + _('sfd')})", [ Namespace.new("somenamespace", "en") ]).to_i18n
    end
    
    def test_controller_variable_parts
      assert_equal "I18n.t('controllers.somenamespace.msg0_a', :a => 'sdasddd', :b => 'sdasd' + I18n.t('controllers.somenamespace.msg1_sfd'))" , GettextI18nConvertor.new("_('a   ' % {:a => 'sdasddd', :b => 'sdasd' + _('sfd')})", [ Namespace.new(["en","controllers","somenamespace"], "en") ], 'controllers').to_i18n
    end
    
    def test_controller_nested_scope
      expected = "I18n.t('controllers.somenamespace.subdir.msg0_trans_will_be')"
      actual = GettextI18nConvertor.new("_('trans will be translated')", [ Namespace.new(["en","controllers","somenamespace","subdir"], "en") ], 'controllers').to_i18n
      assert_equal expected, actual 
    end

    def test_model_nested_scope
      expected = "I18n.t('models.somenamespace.subdir.msg0_trans_will_be')"
      actual = GettextI18nConvertor.new("_('trans will be translated')", [ Namespace.new(["models","somenamespace","subdir"], "en") ], 'models').to_i18n
      assert_equal expected, actual 
    end
    
    def test_helper_nested_scope
      expected = "I18n.t('helpers.somenamespace.subdir.msg0_trans_will_be')"
      actual = GettextI18nConvertor.new("_('trans will be translated')", [ Namespace.new(["en","helpers","somenamespace","subdir"], "en") ], 'helpers').to_i18n
      assert_equal expected, actual 
    end 
    
    def test_mailer_nested_scope
      expected = "I18n.t('mailers.somenamespace.subdir.msg0_trans_will_be')"
      actual = GettextI18nConvertor.new("_('trans will be translated')", [ Namespace.new(["en","mailers","somenamespace","subdir"], "en") ], 'mailers').to_i18n
      assert_equal expected, actual 
    end
    
    def test_lib_nested_scope
      expected = "I18n.t('lib.somenamespace.subdir.msg0_trans_will_be')"
      actual = GettextI18nConvertor.new("_('trans will be translated')", [ Namespace.new(["en","lib","somenamespace","subdir"], "en") ], 'lib').to_i18n
      assert_equal expected, actual 
    end
    
    def test_views_exceptions
      str = "<%=_(\"Invoice: %{desc}\" % {:desc => @invoice.description}) %>"
      t = GettextI18nConvertor.new(str, [ Namespace.new("somenamespace", "en") ])
      assert_equal ":desc => @invoice.description", t.variable_part
      
      str = '_("Information about advertising will soon follow, in the mean time, %{contact}." % {:contact => link_to(_("please contact us"), contact_path)})'
      t = GettextI18nConvertor.new(str, [ Namespace.new("somenamespace", "en") ])
      assert_equal ":contact => link_to(_(\"please contact us\"), contact_path)", t.variable_part
      assert_equal [{:value=>"link_to(t('.msg0_please_contact_us'), contact_path)", :name=>"contact"}], t.variables
    end
    
    def test_views_some_other_string
      str = "_('For more information on large volume plans, customized solutions or (media) partnerships.')"
      assert_equal "t('.msg0_for_more_information')", GettextI18nConvertor.new(str, [ Namespace.new("somenamespace", "en") ],'views').to_i18n
      str = "o << content_tag(:div, _(\"Plan your own home with the free floorplanner\"), :class => \"content\")"
      assert_equal "t('.msg0_plan_your_own')", GettextI18nConvertor.new(str, [ Namespace.new("somenamespace", "en") ],'views').to_i18n
    end
    
    
    def test_quotes
      n = GettextToI18n::Namespace.new("somenamespace", "en")
      str = "_('The easiest way to <span class=\"highlight\">create</span> and<br /> <span class=\"highlight\">share</span> interactive floorplans')"
      t = GettextToI18n::GettextI18nConvertor.new(str, [n])
      assert_equal 'The easiest way to <span class="highlight">create</span> and<br /> <span class="highlight">share</span> interactive floorplans', t.contents
      t = GettextToI18n::GettextI18nConvertor.new("_(\"Save\")", [n])
      assert_equal "Save", t.contents
    end
    
  end
end