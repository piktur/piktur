# frozen_string_literal: true

# rubocop:disable Style/StringLiterals, Style/AlignHash, Metrics/LineLength
# @see activemodel-4.2.5.1/lib/active_model/locale/en.yml
# @see activerecord-4.2.5.1/lib/active_record/locale/en.yml
#
# The values :model, :attribute and :value are always available for interpolation
# The value :count is available when applicable. Can be used for pluralization.
#
# Active Record will look up error messages within these namespaces and in this order:
#   activerecord.errors.models.[model_name].attributes.[attribute_name]
#   activerecord.errors.models.[model_name]
#   activerecord.errors.messages
#   errors.attributes.[attribute_name]
#   errors.messages
#
# Overide default error messages for model
#   [model]:
#     invalid: "%{value} is invalid"
# Overide default error messages per attribute
#   [attribute]:
#     invalid: "%{value} is invalid"
# {
#   en: {
#     activerecord: {
#       errors: {
#         models: {
#           'namespace/model': {
#             attributes: {
#               attribute: {
#                 blank: "%{required} is required"
#               }
#             }
#           }
#         }
#       },
#       models: {
#         'account/base': {
#           attributes: {
#             attribute: {}
#           },
#           one: "Model",
#           other: "Models"
#         }
#       }
#     }
#   }
# }
