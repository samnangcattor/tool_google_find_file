class ToolsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  APPLICATION_NAME= "Moviehdkh"
  OOB_URI = "http://localhost:3000/oauth2callback"
  SCOPE = ["https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/drive.appdata", "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/drive.metadata", "https://www.googleapis.com/auth/drive.metadata.readonly", "https://www.googleapis.com/auth/drive.photos.readonly",
    "https://www.googleapis.com/auth/drive.readonly"]

  def index
    code = params[:code]
    audience = "12448024383-ebq94frerts9fd64sascbau3ro7mvo5p.apps.googleusercontent.com"
    validator = GoogleIDToken::Validator.new
    claim = validator.check(params["id_token"], audience, audience)
    if claim
      session[:user_id] = claim["sub"]
      session[:user_email] = claim["email"]
      200
    else
      401
    end
  end

  def create
    email = params[:email]
    service = Google::Apis::DriveV3::DriveService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    @file_informations = Tool.email_role_file service, email
    render :index
  end

  def update
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end

  private
  def authorize
    client_id = Google::Auth::ClientId.new "12448024383-ebq94frerts9fd64sascbau3ro7mvo5p.apps.googleusercontent.com",
      "Az9t7R4-eica4UqShTHSelUM"
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    authorizer = Google::Auth::WebUserAuthorizer.new client_id, SCOPE, token_store
    user_id = session[:user_id]
    redirect_to "/" if user_id.nil?
    credentials = authorizer.get_credentials user_id, request
    if credentials.nil?
      redirect_to authorizer.get_authorization_url(login_hint: user_id, request: request)
    end
    credentials
  end
end
