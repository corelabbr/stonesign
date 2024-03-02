# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'StoneSign <ola@stonesign.com.br>'
  layout 'mailer'

  register_interceptor ActionMailerConfigsInterceptor

  before_action do
    ActiveStorage::Current.url_options = Stonesign.default_url_options
  end

  def default_url_options
    Stonesign.default_url_options
  end
end
