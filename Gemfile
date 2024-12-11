source "https://rubygems.org"

# TODO: Use Rails 8
gem "rails", "~> 7.2.0"
gem "sqlite3", ">= 1.4" # Use sqlite3 as the database for Active Record
gem "puma", ">= 5.0" # Use the Puma web server [https://github.com/puma/puma]
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "tzinfo-data", platforms: %i[ windows jruby ] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Frontend
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "turbo-rails" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "stimulus-rails" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "tailwindcss-rails" # Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "sprockets-rails" # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]

# API
gem "jbuilder" # Build JSON APIs with ease [https://github.com/rails/jbuilder]

# gem "redis", ">= 4.0.1" # Use Redis adapter to run Action Cable in production
# gem "kredis" # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]

# Active Storage
# gem "image_processing", "~> 1.2" # https://guides.rubyonrails.org/active_storage_overview.html#transforming-images
gem "aws-sdk-s3", "~> 1.176", :require => false

# Auth
gem "devise", "~> 4.9"
gem "omniauth-github", "~> 2.0"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "omniauth", "~> 2.1"

group :development, :test do
  gem "dotenv-rails", "~> 3.1"

  gem "brakeman", require: false
  # TODO: fix rubocop complaints
  gem "rubocop-rails-omakase", require: false

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # ...
end

group :test do
  gem 'simplecov', require: false

  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
