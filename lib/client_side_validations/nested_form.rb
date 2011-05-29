require 'nested_form'

module ClientSideValidations
  module NestedForm
    module Builder

      def self.included(base)
        base.class_eval do
          def self.client_side_form_settings(options, form_helper)
            {
              :type => self.to_s,
              :input_tag => form_helper.class.field_error_proc.call(%{<span id="input_tag" />},  Struct.new(:error_message, :tag_id).new([], "")),
              :label_tag => form_helper.class.field_error_proc.call(%{<label id="label_tag" />}, Struct.new(:error_message, :tag_id).new([], ""))
            }
          end
        end
      end
    end
  end
end

NestedForm::Builder.send(:include, ClientSideValidations::NestedForm::Builder)

module NestedForm
  module ViewHelper
    def nested_form_for_with_client_side_validations(record_or_name_or_array, *args, &block)
      options = args.extract_options!
      object = case record_or_name_or_array
               when Array then record_or_name_or_array.last
               else record_or_name_or_array
               end
      
      @nested_validators = {}
      
      form = nested_form_for_without_client_side_validations(
        record_or_name_or_array, *(args << options), &block)
      
      form << client_side_nested_form_settings(object, options)
    end
    alias_method_chain :nested_form_for, :client_side_validations

    def client_side_nested_form_settings(object, options)
      if options[:validate]
        var_name = client_side_form_id(object, options)
        
        blueprint_validators = {}
        @validators.each do |name, rules|
          object = '[^\[\]]+'
          attrs = '\[[^\[\]]+_attributes\]'
          new_index = '\[new_([^\[\]]+)\]'
          
          if name =~ /^#{object}(#{attrs})+#{new_index}/
            blueprint_validators[name] = rules
          end
        end
        
        content_tag(:script) do
          "window['#{var_name}']['blueprint_validators'] = #{blueprint_validators.to_json};".html_safe
        end
      end
    end
  end
end
