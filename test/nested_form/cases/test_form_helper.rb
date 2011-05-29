require 'action_view/cases/helper'
require 'nested_form/cases/helper'

# require 'ruby-debug19'

class ClientSideValidations::NestedForm::FormHelperTest < ActionView::TestCase
  include ActionViewTestSetup
  include NestedForm::ViewHelper

  cattr_accessor :field_error_proc
  @@field_error_proc = Proc.new { |html_tag, instance| html_tag }

  def setup
    @project = Project.new
  end
  
  def test_nested_form
    # @project.tasks.build
    nested_form_for(@project, :url => '/projects/123', :validate => true) do |f|
      # concat f.text_field(:title)
      concat f.fields_for(:tasks) { |t|
        concat t.text_field(:name)
      }
      concat f.link_to_add('Add Task', :tasks)
    end

    validator_templates = {'project[tasks_attributes][new_tasks][name]' => {:presence => {:message => "can't be blank"}}}
    
    expected = %{<form accept-charset="UTF-8" action="/projects/123" class="new_project" data-validate="true" id="new_project" method="post" novalidate="novalidate"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div><a href="javascript:void(0)" class="add_nested_fields" data-association="tasks">Add Task</a></form><script>window['new_project'] = {\"type\":\"NestedForm::Builder\",\"input_tag\":\"<span id=\\\"input_tag\\\" />\",\"label_tag\":\"<label id=\\\"label_tag\\\" />\",\"validators\":{}};</script><div id="tasks_fields_blueprint" style="display: none"><div class="fields"><input data-validate="true" id="project_tasks_attributes_new_tasks_name" name="project[tasks_attributes][new_tasks][name]" size="30" type="text" /></div></div><script>window['new_project']['blueprint_validators'] = #{validator_templates.to_json};</script>}

    assert_equal expected, output_buffer
  end
end

