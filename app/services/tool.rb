class Tool
  class << self
    def get_list_files service
      result = []
      list_files = service.list_files corpus: "domain", max_results: 1000, q: "mimeType != 'application/vnd.google-apps.folder'"
      list_files.items.each do|file|
        unless file.mime_type.include?("application/vnd.google-apps.folder")
          result << {"title": file.title, "alert_link": file.alternate_link}
        end
      end
      result
    end
  end
end
