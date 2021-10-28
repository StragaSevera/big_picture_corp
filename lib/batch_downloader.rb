# frozen_string_literal: true

require './lib/file_downloader'
require 'bundler'
Bundler.require(:default, :development)

class BatchDownloader
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def download
    puts 'Download started...'
    image_links.each do |uri|
      result = FileDownloader.new(uri).download
      puts "Cannot download #{uri}" unless result
    end
    puts 'Download finished!'
  end

  def image_links
    File.readlines(filename).flat_map(&:split)
  end
end
