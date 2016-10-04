require_relative "boot"

require "rails/all"
require "google/apis/drive_v2"
require "googleauth"
require "googleauth/stores/file_token_store"

# Require the gems listed in Gemfile, including any gems
# you"ve limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FindFileShare
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
