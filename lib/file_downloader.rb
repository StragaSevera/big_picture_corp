# frozen_string_literal: true

require 'down/http'

class FileDownloader
  attr_reader :base_url, :download_to, :filename

  MAX_SIZE = 50 * 1024 * 1024

  def initialize(url:, download_to:)
    @base_url = url
    @download_to = download_to
    @filename = "#{download_to}/#{url.split('/').last}"
  end

  def download
    if base_url.start_with?('http://', 'https://')
      download_file
    else
      download_unprefixed
    end
  end

  private

  UNPREFIXED_BREAK_ON = [Symbol, Down::TooLarge, Down::TooManyRedirects].freeze

  def download_unprefixed
    prefixed_urls = %W[https://#{base_url} http://#{base_url}]
    result = nil
    prefixed_urls.each do |prefixed_url|
      result = download_file(prefixed_url)
      UNPREFIXED_BREAK_ON.any? { |klass| result.is_a? klass } ? break : next
    end
    result
  end

  def download_file(url = base_url)
    Down::Http.download(url, destination: filename, max_size: MAX_SIZE)
    :ok
  rescue Down::Error => e
    e
  end
end
