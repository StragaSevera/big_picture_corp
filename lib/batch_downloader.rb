# frozen_string_literal: true

require './lib/file_downloader'
require 'bundler'
Bundler.require(:default, :development)

class BatchDownloader
  attr_reader :filename, :download_to

  def initialize(filename:, download_to: 'download')
    @filename = filename
    @download_to = download_to
  end

  def download
    puts 'Download started...'
    image_links.each do |url|
      result = FileDownloader.new(url: url, download_to: download_to).download
      puts "Cannot download #{url}" unless result
    end
    puts 'Download finished!'
  end

  def image_links
    File.readlines(filename).flat_map(&:split)
  end
end
