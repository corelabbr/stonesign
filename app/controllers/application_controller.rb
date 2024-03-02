# frozen_string_literal: true

class ApplicationController < ActionController::Base
  BROWSER_LOCALE_REGEXP = /\A\w{2}(?:-\w{2})?/

  include ActiveStorage::SetCurrent
  include Pagy::Backend

  check_authorization unless: :devise_controller?

  before_action :sign_in_for_demo, if: -> { Stonesign.demo? }
  before_action :maybe_redirect_to_setup, unless: :signed_in?
  before_action :authenticate_user!, unless: :devise_controller?

  helper_method :button_title,
                :current_account,
                :svg_icon

  rescue_from Pagy::OverflowError do
    redirect_to request.path
  end

  if Rails.env.production?
    rescue_from CanCan::AccessDenied do |e|
      Rollbar.error(e) if defined?(Rollbar)

      redirect_back(fallback_location: root_path, alert: e.message)
    end
  end

  def default_url_options
    Stonesign.default_url_options
  end

  private

  def with_browser_locale(&)
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].to_s[BROWSER_LOCALE_REGEXP].to_s

    locale =
      if locale.starts_with?('en-') && locale != 'en-US'
        'en-GB'
      else
        locale.split('-').first.presence || 'en-GB'
      end

    locale = 'en-GB' unless I18n.locale_available?(locale)

    I18n.with_locale(locale, &)
  end

  def sign_in_for_demo
    sign_in(User.active.order('random()').take) unless signed_in?
  end

  def current_account
    current_user&.account
  end

  def maybe_redirect_to_setup
    redirect_to setup_index_path unless User.exists?
  end

  def button_title(title: 'Submit', disabled_with: 'Submitting', title_class: '', icon: nil, icon_disabled: nil)
    render_to_string(partial: 'shared/button_title',
                     locals: { title:, disabled_with:, title_class:, icon:, icon_disabled: })
  end

  def svg_icon(icon_name, class: '')
    render_to_string(partial: "icons/#{icon_name}", locals: { class: })
  end
end
