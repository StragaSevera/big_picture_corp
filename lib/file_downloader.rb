# frozen_string_literal: true

require 'open-uri'

class FileDownloader
  attr_reader :url, :download_to

  def initialize(url:, download_to:)
    @url = url
    @download_to = download_to
  end

  def download
    filename = "#{download_to}/#{url.split('/').last}"
    URI.parse(url).open do |uri_file|
      File.write(filename, uri_file.read)
    end
    true
  rescue OpenURI::HTTPError
    false
  end
end
