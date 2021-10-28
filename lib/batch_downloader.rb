# frozen_string_literal: true

class BatchDownloader
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def download
    puts "Parsing #{filename}"
    puts 'Download started...'
  end
end
