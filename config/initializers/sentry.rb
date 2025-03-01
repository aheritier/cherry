# frozen_string_literal: true

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.traces_sample_rate = 0.2
    config.excluded_exceptions = [ActionController::RoutingError]
  end
end
