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
    each_image_link do |url|
      result = FileDownloader.new(url: url, download_to: download_to).download
      puts "Cannot download #{url}" unless result
    end
    puts 'Download finished!'
  end

  def each_image_link(&block)
    File.foreach(filename) do |line|
      line.split.each(&block)
    end
  end
end
