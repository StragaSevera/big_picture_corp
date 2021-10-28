# frozen_string_literal: true

require 'open-uri'

class FileDownloader
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def download
    filename = "download/#{url.split('/').last}"
    URI.parse(url).open do |uri_file|
      File.write(filename, uri_file.read)
    end
    true
  rescue OpenURI::HTTPError
    false
  end
end
