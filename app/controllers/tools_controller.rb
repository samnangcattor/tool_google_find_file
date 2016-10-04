class ToolsController < ApplicationController
  OOB_URI = "http://localhost:3000/oauth2callback"
  APPLICATION_NAME = "Moviehdkh"
  CLIENT_SECRETS_PATH = "lib/google_drive/client_secret.json"
  SCOPE = ["https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/drive.appdata", "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/drive.metadata", "https://www.googleapis.com/auth/drive.metadata.readonly", "https://www.googleapis.com/auth/drive.photos.readonly",
    "https://www.googleapis.com/auth/drive.readonly"]

  def index
  end

  def create
    email = params[:email]
    user_emails = User.all.map &:email
    service = Google::Apis::DriveV2::DriveService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize user_emails, email
    @file_informations = Tool.get_list_files service
    render :index
  end

  def update
    user = User.last
    user_id = user.id
    file_yaml = "tool-#{user_id}.yaml"
    credentials_path = File.join("lib/google_drive/", ".credentials", file_yaml)
    client_id = Google::Auth::ClientId.from_file CLIENT_SECRETS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: credentials_path
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    credentials = authorizer.get_credentials user_id
    code = params[:code]
    credentials = authorizer.get_and_store_credentials_from_code user_id: user_id, code: code, base_url: OOB_URI
    redirect_to tools_path
  end

  private
  def authorize user_emails, email
    unless user_emails.include? email
      User.create email: email
    end
    user = User.find_by email: email
    user_id = user.id
    file_yaml = "tool-#{user_id}.yaml"
    credentials_path = File.join "lib/google_drive/", ".credentials", file_yaml
    FileUtils.mkdir_p File.dirname(credentials_path)
    client_id = Google::Auth::ClientId.from_file CLIENT_SECRETS_PATH
    token_store = Google::Auth::Stores::FileTokenStore.new file: credentials_path
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    credentials = authorizer.get_credentials user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      redirect_to url
    end
    credentials
  end
end
