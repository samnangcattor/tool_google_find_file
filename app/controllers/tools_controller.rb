class ToolsController < ApplicationController
  OOB_URI = "http://localhost:3000/oauth2callback"
  APPLICATION_NAME = "Movidhdkh"
  CLIENT_SECRETS_PATH = "lib/google_drive/client_secret.json"
  CREDENTIALS_PATH = File.join "lib/google_drive/", ".credentials", "moviehdkh-com.yaml"
  SCOPE = "https://www.googleapis.com/auth/drive"

  def index
    code = params[:code]
    if code.present?
      email = params[:email]
      service = Google::Apis::DriveV3::DriveService.new
      service.client_options.application_name = APPLICATION_NAME
      author = authorize
      service.authorization = author[:credentials]
      @file_informations = Tool.email_role_file service, email
    end
  end

  def create
    email = params[:email]
    user_id = session["session_id"]
    service = Google::Apis::DriveV3::DriveService.new
    service.client_options.application_name = APPLICATION_NAME
    author = authorize
    service.authorization = author[:credentials]
    @file_informations = Tool.email_role_file service, email
    render :index
  rescue
    redis = Redis.new
    redis.set user_id, email
    url = author[:url]
    redirect_to url
  end

  def update
    code = params[:code]
    if code.present?
      client_id = Google::Auth::ClientId.from_file CLIENT_SECRETS_PATH
      token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
      authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
      redis = Redis.new
      user_id = session["session_id"]
      credentials = authorizer.get_credentials user_id
      credentials = authorizer.get_and_store_credentials_from_code user_id: user_id, code: code, base_url: OOB_URI
      email = redis.get user_id
    end
    redirect_to tools_path(code: code, email: email)
  end

  private
  def authorize
    client_id = Google::Auth::ClientId.from_file CLIENT_SECRETS_PATH
    token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = session["session_id"]
    credentials = authorizer.get_credentials user_id if user_id.present?
    url = authorizer.get_authorization_url base_url: OOB_URI
    {"credentials": credentials, "url": url}
  end
end
