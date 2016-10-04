class Tool
  class << self
    def email_role_file service, email
      result = []
      files = list_information_files service
      files.each do |file|
        result << file if file[:permission_members].include? email
      end
      result
    end

    def list_information_files service
      files = get_list_files service
      files.inject([]) do |arr, file|
        permission_members = permission_file_members service, file[:id]
        arr << {"title": file[:title], "alert_link": file[:alert_link], "permission_members": permission_members}
      end
    end

    def get_list_files service
      result = []
      list_files = service.list_files corpus: "domain", max_results: 1000, q: "mimeType != 'application/vnd.google-apps.folder'"
      list_files.items.each do|file|
        result << {"title": file.title, "alert_link": file.alternate_link, "id": file.id}
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
