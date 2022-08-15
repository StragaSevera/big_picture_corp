# frozen_string_literal: true

require './lib/file_downloader'
require 'bundler'
Bundler.require(:default)

class BatchDownloader
  THREADS_AMOUNT = 4
  MAX_LINKS = 1024

  def initialize(filename:, download_to: 'download')
    @filename = filename
    @download_to = download_to
    @queue = Thread::SizedQueue.new(MAX_LINKS)
  end

  def download
    prepare_download_folder
    puts 'Download started!'

    threads = []
    threads << Thread.new(&method(:parse_links))
    threads += THREADS_AMOUNT.times.map { Thread.new(&method(:download_files)) }

    threads.each(&:join)
    puts "\nDownload finished!"
  end

  private

  attr_reader :filename, :download_to, :queue

  def prepare_download_folder
    FileUtils.mkdir_p('download')
  end

  def parse_links
    File.foreach(filename) do |link|
      queue.push(link.strip)
    end
    queue.close
  end

  def download_files
    while (link = queue.pop)
      download_file(link)
    end
  end

  def download_file(url)
    result = FileDownloader.new(url: url, download_to: download_to).download
    if result == :ok
      print '.'
    else
      warn "Cannot download #{url}: #{result}"
    end
  end
end
