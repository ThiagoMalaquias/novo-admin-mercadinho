require "logger"
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module AdminSkalMercado24hrs
  class Application < Rails::Application
    config.load_defaults 6.1

    config.i18n.available_locales = [:en, :"pt-BR"]
    config.i18n.default_locale = :"pt-BR"

    config.time_zone = "Brasilia"
    config.active_storage.queue = :active_storage

    ActiveStorage::Engine.config
                         .active_storage
                         .content_types_to_serve_as_binary
                         .delete("image/svg+xml")
  end
end
