# frozen_string_literal: true

module Accounts
  module_function

  def create_duplicate(account)
    new_account = account.dup

    new_user = account.users.first.dup

    new_user.uuid = SecureRandom.uuid
    new_user.account = new_account
    new_user.encrypted_password = SecureRandom.hex
    new_user.email = "#{SecureRandom.hex}@stonesign.co"

    account.templates.each do |template|
      new_template = template.dup

      new_template.account = new_account
      new_template.slug = SecureRandom.base58(14)

      new_template.archived_at = nil
      new_template.save!

      Templates::CloneAttachments.call(template: new_template, original_template: template)
    end

    new_user.save!(validate: false)
    new_account.templates.update_all(folder_id: new_account.default_template_folder.id)

    new_account
  end

  def create_default_template(account)
    template = Template.find(1)

    new_template = Template.find(1).dup
    new_template.account_id = account.id
    new_template.slug = SecureRandom.base58(14)
    new_template.folder = account.default_template_folder

    new_template.save!

    Templates::CloneAttachments.call(template: new_template, original_template: template)

    new_template
  end

  def load_webhook_configs(account)
    configs = account.encrypted_configs.find_by(key: EncryptedConfig::WEBHOOK_URL_KEY)

    unless Stonesign.multitenant?
      configs ||= Account.order(:id).first.encrypted_configs.find_by(key: EncryptedConfig::WEBHOOK_URL_KEY)
    end

    configs
  end

  def load_signing_pkcs(account)
    cert_data =
      if Stonesign.multitenant?
        EncryptedConfig.find_by(account:, key: EncryptedConfig::ESIGN_CERTS_KEY)&.value || Stonesign::CERTS
      else
        EncryptedConfig.find_by(key: EncryptedConfig::ESIGN_CERTS_KEY).value
      end

    if (default_cert = cert_data['custom']&.find { |e| e['status'] == 'default' })
      OpenSSL::PKCS12.new(Base64.urlsafe_decode64(default_cert['data']), default_cert['password'].to_s)
    else
      GenerateCertificate.load_pkcs(cert_data)
    end
  end

  def load_timeserver_url(account)
    if Stonesign.multitenant?
      Stonesign::TIMESERVER_URL
    else
      url = EncryptedConfig.find_by(account:, key: EncryptedConfig::TIMESTAMP_SERVER_URL_KEY)&.value

      unless Stonesign.multitenant?
        url ||=
          Account.order(:id).first.encrypted_configs.find_by(key: EncryptedConfig::TIMESTAMP_SERVER_URL_KEY)&.value
      end

      url
    end.presence
  end

  def can_send_emails?(_account)
    return true if Stonesign.multitenant?
    return true if ENV['SMTP_ADDRESS'].present?

    EncryptedConfig.exists?(key: EncryptedConfig::EMAIL_SMTP_KEY)
  end

  def normalize_timezone(timezone)
    tzinfo = TZInfo::Timezone.get(ActiveSupport::TimeZone::MAPPING[timezone] || timezone)

    ::ActiveSupport::TimeZone.all.find { |e| e.tzinfo == tzinfo }&.name || timezone
  rescue TZInfo::InvalidTimezoneIdentifier
    'UTC'
  end
end
