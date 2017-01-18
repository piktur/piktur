# frozen_string_literal: true

# rubocop:disable Style/StringLiterals, Style/AlignHash, Metrics/LineLength
# @see activemodel-4.2.5.1/lib/active_model/locale/en.yml
#
# @note refer to Model.model_name.i18n_key to confirm i18n key
#   > Site::Template.model_name.i18n_key
#   => :"site/template"
#
# The default format to use in full error messages.
# format: "%{attribute} %{message}",
# The values :model, :attribute and :value are always available for interpolation
# The value :count is available when applicable. Can be used for pluralization.
#
# Active Record will look up error messages within these namespaces and in this order:
#   activerecord.errors.models.[model_name].attributes.[attribute_name]
#   activerecord.errors.models.[model_name]
#   activerecord.errors.messages
#   errors.attributes.[attribute_name]
#   errors.messages
{
  en: {
    errors: {
      messages: {
        inclusion:      "is not included in the list",
        exclusion:      "is reserved",
        invalid:        "is invalid",
        confirmation:   "doesn't match %{attribute}",
        accepted:       "must be accepted",
        empty:          "can't be empty",
        blank:          "can't be blank",
        present:        "must be blank",
        taken:          "has already been taken",
        too_long: {
          one:   "is too long (maximum is 1 character)",
          other: "is too long (maximum is %{count} characters)"
        },
        too_short: {
          one:   "is too short (minimum is 1 character)",
          other: "is too short (minimum is %{count} characters)"
        },
        wrong_length: {
          one:   "is the wrong length (should be 1 character)",
          other: "is the wrong length (should be %{count} characters)"
        },
        not_a_number:   "is not a number",
        not_an_integer: "must be an integer",
        greater_than:   "must be greater than %{count}",
        greater_than_or_equal_to: "must be greater than or equal to %{count}",
        equal_to:       "must be equal to %{count}",
        less_than:      "must be less than %{count}",
        less_than_or_equal_to: "must be less than or equal to %{count}",
        other_than:     "must be other than %{count}",
        odd:            "must be odd",
        even:           "must be even"
      }
      # attributes: {
      #   [attribute_name]: {  }
      # }
    },
    activerecord: {
      errors: {
        # Defaults
        messages: {
          # error: "message"
        }
      }
    }
  }
}
