# frozen_string_literal: true

require 'down/http'

class FileDownloader
  attr_reader :url, :download_to, :filename

  MAX_SIZE = 50 * 1024 * 1024

  def initialize(url:, download_to:)
    @url         = url
    @download_to = download_to
    @filename = "#{download_to}/#{url.split('/').last}"
  end

  def download
    if url.start_with?('http://', 'https://')
      download_prefixed
    else
      download_unprefixed
    end
  end

  private

  def download_prefixed
    download_file(url)
    :ok
  rescue Down::Error
    :error
  end

  def download_unprefixed
    urls = %W[https://#{url} http://#{url}]
    urls.each do |url|
      download_file(url)
      return :ok
    rescue Down::TooLarge, Down::TooManyRedirects
      return :error
    rescue Down::Error
      next
    end
    :error
  end

  def download_file(url)
    Down::Http.download(url, destination: filename, max_size: MAX_SIZE)
  end
end
