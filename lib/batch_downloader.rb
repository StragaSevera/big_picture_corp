# frozen_string_literal: true

require './lib/file_downloader'
require 'bundler'
Bundler.require(:default)

class BatchDownloader
  attr_reader :filename, :download_to

  def initialize(filename:, download_to: 'download')
    @filename = filename
    @download_to = download_to
  end

  THREADS_AMOUNT = 4
  def download
    puts 'Download started...'
    threads = []
    each_image_link do |url|
      threads << Thread.new(url) do |thread_url|
        result = FileDownloader.new(url: thread_url, download_to: download_to).download
        puts "Cannot download #{thread_url}" unless result
      end
      if threads.size >= THREADS_AMOUNT
        finished_thread = ThreadsWait.new(*threads).next_wait
        threads.delete(finished_thread)
      end
    rescue ErrNoWaitingThread
      # Ignored
    end
    ThreadsWait.all_waits(*threads)
    puts 'Download finished!'
  end

  def each_image_link(&block)
    File.foreach(filename) do |line|
      line.split.each(&block)
    end
  end
end
