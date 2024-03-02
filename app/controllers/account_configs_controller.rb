# frozen_string_literal: true

class AccountConfigsController < ApplicationController
  before_action :load_account_config
  authorize_resource :account_config

  ALLOWED_KEYS = [
    AccountConfig::ALLOW_TYPED_SIGNATURE,
    AccountConfig::FORCE_MFA,
    AccountConfig::ESIGNING_PREFERENCE_KEY
  ].freeze

  def create
    @account_config.update!(account_config_params)

    head :ok
  end

  private

  def load_account_config
    return head :not_found unless ALLOWED_KEYS.include?(account_config_params[:key])

    @account_config =
      AccountConfig.find_or_initialize_by(account: current_account, key: account_config_params[:key])
  end

  def account_config_params
    params.required(:account_config).permit!.tap do |attrs|
      attrs[:value] = attrs[:value] == '1' if attrs[:value].in?(%w[1 0])
    end
  end
end
