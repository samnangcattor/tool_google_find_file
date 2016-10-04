class Tool
  class << self
    def get_list_files service
      list_files = service.list_files corpus: "domain"
      list_files.items.inject([]) do|arr, file|
        arr << {"title": file.title, "alert_link": file.alternate_link}
      end
    end
  end
end
