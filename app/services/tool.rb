class Tool
  class << self
    def email_role_file service, email
      result = []
      files = get_list_files service, email
      files
    end

    def list_information_files service
      files = get_list_files service
      files.inject([]) do |arr, file|
        permission_members = permission_file_members service, file[:id]
        arr << {"title": file[:title], "alert_link": file[:alert_link], "permission_members": permission_members}
      end
    end

    def get_list_files service, email
      result = []
      list_files = service.list_files corpus: "user", page_size: 1000, q: "mimeType != 'application/vnd.google-apps.folder'",
        fields: "files(name,permissions/emailAddress,webViewLink)"
      list_files.files.each do|file|
        permission_email = file.permissions.present? ? file.permissions.map(&:email_address) : []
        if permission_email.include? email
          result << {"title": file.name, "alert_link": file.web_view_link}
        end
      end
      result
    end

    def permission_file_members service, file_id
      list_permissions = service.list_permissions file_id
      list_permissions.items.inject([]) do |arr, permssion|
        arr << permssion.email_address
      end
    end
  end
end
