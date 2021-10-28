# frozen_string_literal: true

require 'down'

class FileDownloader
  attr_reader :url, :download_to

  def initialize(url:, download_to:)
    @url = url
    @download_to = download_to
  end

  def download
    filename = "#{download_to}/#{url.split('/').last}"
    Down.download(url, destination: filename, max_size: 50 * 1024 * 1024)
    true
  rescue Down::Error
    false
  end
end
