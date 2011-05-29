require 'nested_form/cases/helper'

class ClientSideValidations::NestedForm::BuilderTest < Test::Unit::TestCase
  class MockFormHelper
    def self.field_error_proc
      lambda { |html_tag, instance| html_tag }
    end
  end
    
  def test_client_side_form_js_hash
    expected = {
      :type => 'NestedForm::Builder',
      :input_tag => %{<span id="input_tag" />},
      :label_tag => %{<label id="label_tag" />}
    }
    assert_equal expected, NestedForm::Builder.client_side_form_settings(nil, MockFormHelper.new)
  end
end
