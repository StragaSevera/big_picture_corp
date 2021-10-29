# frozen_string_literal: true

require './lib/file_downloader'
require 'bundler'
Bundler.require(:default)

class BatchDownloader
  attr_reader :filename, :download_to

  THREADS_AMOUNT = 4

  def initialize(filename:, download_to: 'download')
    @filename = filename
    @download_to = download_to
    @threads = []
  end

  def download
    prepare_download_folder
    puts 'Download started...'
    each_image_link do |url|
      threads << Thread.new(url, &method(:download_file))
      handle_next_thread if threads.size >= THREADS_AMOUNT
    end
    ThreadsWait.all_waits(*threads)
    puts 'Download finished!'
  end

  private

  attr_reader :threads

  def prepare_download_folder
    Dir.mkdir('download') unless File.exist?('download')
  end

  def each_image_link(&block)
    File.foreach(filename) do |line|
      line.split.each(&block)
    end
  end

  def download_file(url)
    result = FileDownloader.new(url: url, download_to: download_to).download
    puts "Cannot download #{url}" unless result
  end

  def handle_next_thread
    finished_thread = ThreadsWait.new(*threads).next_wait
    threads.delete(finished_thread)
  rescue ErrNoWaitingThread
    # Ignored
  end
end
