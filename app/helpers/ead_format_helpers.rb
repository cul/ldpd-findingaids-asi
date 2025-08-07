# frozen_string_literal: true

module EadFormatHelpers
  include Arclight::EadFormatHelpers

  private

  def format_render_attributes(node)
    # Remove the type attribute as it isn't valid HTML.
    # 
    # This will be addressed in the upstream Arclight core:
    # https://github.com/projectblacklight/arclight/pull/1605
    node.remove_attribute('type')

    # Call the original method from the included Arclight::EadFormatHelpers module
    super
  end
end
