# frozen_string_literal: true

class ConsoleRedirectController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def index
    return redirect_to(new_user_session_path({ redir: params[:redir] }.compact)) if current_user.blank?

    auth = JsonWebToken.encode(uuid: current_user.uuid,
                               scope: :console,
                               exp: 1.minute.from_now.to_i)

    path = Addressable::URI.parse(params[:redir]).path if params[:redir].to_s.starts_with?(Stonesign::CONSOLE_URL)

    redirect_to("#{Stonesign::CONSOLE_URL}#{path}?#{{ auth: }.to_query}", allow_other_host: true)
  end
end
