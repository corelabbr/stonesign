# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount Sidekiq::Web => '/sidekiq' if defined?(Sidekiq)

  root 'dashboard#index'

  get 'up' => 'rails/health#show'

  devise_for :users,
             path: '/', only: %i[sessions passwords omniauth_callbacks],
             controllers: begin
               options = { sessions: 'sessions', passwords: 'passwords' }
               options[:omniauth_callbacks] = 'omniauth_callbacks' if User.devise_modules.include?(:omniauthable)
               options
             end

  devise_scope :user do
    if Stonesign.multitenant?
      resource :registration, only: %i[show], path: 'sign_up'
      unauthenticated do
        resource :registration, only: %i[create], path: 'new' do
          get '' => :new, as: :new
        end
      end
    end

    resource :invitation, only: %i[update] do
      get '' => :edit
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :attachments, only: %i[create]
    resources :submitters_autocomplete, only: %i[index]
    resources :template_folders_autocomplete, only: %i[index]
    resources :submitter_email_clicks, only: %i[create]
    resources :submitter_form_views, only: %i[create]
    resources :submitters, only: %i[index show update]
    resources :submissions, only: %i[index show create destroy] do
      collection do
        resources :emails, only: %i[create], controller: 'submissions', as: :submissions_emails
      end
    end
    resources :templates, only: %i[update show index destroy] do
      resources :clone, only: %i[create], controller: 'templates_clone'
      resources :submissions, only: %i[index create]
      resources :documents, only: %i[create], controller: 'templates_documents'
    end
  end

  resources :verify_pdf_signature, only: %i[create]
  resource :mfa_setup, only: %i[show new edit create destroy], controller: 'mfa_setup'
  resources :account_configs, only: %i[create]
  resources :timestamp_server, only: %i[create]
  resources :dashboard, only: %i[index]
  resources :setup, only: %i[index create]
  resource :newsletter, only: %i[show update]
  resources :enquiries, only: %i[create]
  resources :users, only: %i[new create edit update destroy]
  resource :user_signature, only: %i[edit update destroy]
  resources :submissions, only: %i[show destroy]
  resources :console_redirect, only: %i[index]
  resource :templates_upload, only: %i[create]
  authenticated do
    resource :templates_upload, only: %i[show], path: 'new'
  end
  resources :templates_archived, only: %i[index], path: 'archived'
  resources :folders, only: %i[show edit update destroy], controller: 'template_folders'
  resources :templates, only: %i[new create edit show destroy] do
    resources :restore, only: %i[create], controller: 'templates_restore'
    resources :archived, only: %i[index], controller: 'templates_archived_submissions'
    resources :submissions, only: %i[new create]
    resource :folder, only: %i[edit update], controller: 'templates_folders'
    resources :submissions_export, only: %i[index new]
  end
  resources :preview_document_page, only: %i[show], path: '/preview/:attachment_uuid'

  resources :start_form, only: %i[show update], path: 'd', param: 'slug' do
    get :completed
  end

  resources :submit_form, only: %i[show update], path: 's', param: 'slug' do
    get :completed
  end

  resources :submissions_preview, only: %i[show], path: 'e', param: 'slug'

  resources :send_submission_email, only: %i[create] do
    get :success, on: :collection
  end

  resources :submitters, only: %i[], param: 'slug' do
    resources :download, only: %i[index], controller: 'submissions_download'
    resources :send_email, only: %i[create], controller: 'submitters_send_email'
    resources :debug, only: %i[index], controller: 'submissions_debug' if Rails.env.development?
  end

  scope '/settings', as: :settings do
    unless Stonesign.multitenant?
      resources :storage, only: %i[index create], controller: 'storage_settings'
      resources :email, only: %i[index create], controller: 'email_smtp_settings'
      resources :sms, only: %i[index], controller: 'sms_settings'
      resources :sso, only: %i[index], controller: 'sso_settings'
    end
    resources :notifications, only: %i[index create], controller: 'notifications_settings'
    resource :esign, only: %i[show create new update destroy], controller: 'esign_settings'
    resources :users, only: %i[index]
    resource :personalization, only: %i[show create], controller: 'personalization_settings'
    if !Stonesign.multitenant? || Stonesign.demo?
      resources :api, only: %i[index create], controller: 'api_settings'
      resource :webhooks, only: %i[show create update], controller: 'webhook_settings'
    end
    resource :account, only: %i[show update]
    resources :profile, only: %i[index] do
      collection do
        patch :update_contact
        patch :update_password
        patch :update_app_url
      end
    end
  end

  ActiveSupport.run_load_hooks(:routes, self)
end
