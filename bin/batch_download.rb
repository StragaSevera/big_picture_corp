# frozen_string_literal: true

require './lib/batch_downloader'

if ARGV.length != 1
  STDERR.puts 'Wrong number of arguments'
  exit
end

BatchDownloader.new(filename: ARGV[0]).download
