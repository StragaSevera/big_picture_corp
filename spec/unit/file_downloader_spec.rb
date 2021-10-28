# frozen_string_literal: true

require 'rspec'
require 'fileutils'
require './lib/file_downloader'

describe FileDownloader do
  around(:each) do |example|
    old_files = Dir.entries('download').to_set
    example.run
    new_files = Dir.entries('download').to_set

    (new_files - old_files).each { |filename| File.delete("download/#{filename}") }
  end

  context 'when url is valid' do
    subject { FileDownloader.new('https://rubyonrails.org/images/rubyrails.png') }

    let(:result) do
      VCR.use_cassette('correct_url') do
        subject.download
      end
    end

    it 'returns true' do
      expect(result).to be true
    end

    it 'saves the image' do
      result
      expect(File.exist?('download/rubyrails.png')).to be true
      expect(FileUtils.compare_file('download/rubyrails.png', 'spec/fixtures/images/rubyrails.png')).to be true
    end
  end

  context 'when url is invalid' do
    subject { FileDownloader.new('https://rubyonrails.org/images/wrong.png') }

    let(:result) do
      VCR.use_cassette('incorrect_url') do
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
