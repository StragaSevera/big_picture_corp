# frozen_string_literal: true

require 'rspec'
require 'fileutils'
require './lib/file_downloader'

describe FileDownloader do
  before(:all) do
    FileUtils.mkdir_p('tmp')
  end

  around(:each) do |example|
    old_files = Dir.entries('tmp').to_set
    example.run
    new_files = Dir.entries('tmp').to_set

    (new_files - old_files).each { |filename| File.delete("tmp/#{filename}") }
  end

  context 'when url is valid' do
    subject do
      FileDownloader.new(url: 'https://rubyonrails.org/images/rubyrails.png', download_to: 'tmp')
    end

    let(:result) do
      VCR.use_cassette('file_downloader/correct_url') do
        subject.download
      end
    end

    it 'returns true' do
      expect(result).to be true
    end

    it 'saves the image' do
      result
      expect(File.exist?('tmp/rubyrails.png')).to be true
      expect(FileUtils.compare_file('tmp/rubyrails.png', 'spec/fixtures/images/rubyrails.png')).to be true
    end
  end

  context 'when url is invalid' do
    subject do
      FileDownloader.new(url: 'https://rubyonrails.org/images/wrong.png', download_to: 'tmp')
    end

    let(:result) do
      VCR.use_cassette('file_downloader/incorrect_url') do
        subject.download
      end
    end

    it 'returns false' do
      expect(result).to be false
    end

    it 'does not save the image' do
      result
      expect(File.exist?('download/wrong.png')).to be false
    end
  end
end
