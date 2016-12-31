# frozen_string_literal: true

# DRY `ActiveSupport::Dependencies.require_dependencies`
#
# Constants defined under `._all_autoload_paths` are loaded during
#   `Rails.application.initialize!`, or lazy loaded to reduce boot time in development.
#   Use `ActiveSupport::Dependencies.require_dependency` rather than `require` or
#   `ActiveSupport::Autoload.eager_load!` to load dependencies in development.
#   This also applies to code under `/lib` which, when added to `config.watchable_dirs` and
#   code within it is loaded with `require_dependency`, will be reloaded before each request
#   in development.
#
#   {file:config/environments/development.rb}
#   {link:https://bitbucket.org/piktur/piktur_api/issues/14/fix-controller-namespacing}
#
#   Modules defined in `lib/piktur/api.rb` must be loaded up front to ensure correct constant
#   lookup in development.
#
#   ```ruby
#     # const_get will return root level constant if parent not defined
#     Rails.env.development?
#     => true
#     Object.const_defined?('Piktur::Api::V1::Admin::Asset')
#     => false
#     Object.const_get('Piktur::Api::V1::Admin::Asset::Audio')
#     => Asset::Audio
#
#     # after parent loaded
#     require_dependency 'app/serializers/piktur/api/v1/admin/asset/base_serializer.rb'
#     Object.const_defined?('Piktur::Api::V1::Admin::Asset')
#     => true'
#     # the correct constant is returned
#     Object.const_get('Piktur::Api::V1::Admin::Asset::AudioSerializer')
#     => Piktur::Api::V1::Admin::Asset::AudioSerializer
#   ```
#
# @note For convenience add deeply nested paths to `Rails.application.config.autoload_paths` to
#   further limit redundancy in require statements. {file:config/application.rb}
#   `require_dependency` must receive the relative path from `Rails.root` if called before
#   `Rails.application.initialize!` when `._all_autoload_paths` defined.
#
# @example
#   require_dependencies('app/serializers/piktur/api/v1/catalogue/attribution_serializer')
#   require_dependencies('v1/catalogue/attribution_serializer')
#   require_dependencies 'v1/client/catalogue', type: :serializer
#
# @param [String, Object] type [:controller, :serializer, :policy, :presenter]
# @param [String] args
# @return [Boolean]
def require_dependencies(*args, type: nil)
  args.each { |f| require_dependency "#{f}#{'_' + type.to_s if type}.rb" } unless Rails.env.production?
end