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

    it 'returns correct result' do
      expect(result).to eq :ok
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

    it 'returns correct result' do
      expect(result).to eq :error
    end

    it 'does not save the image' do
      result
      expect(File.exist?('download/wrong.png')).to be false
    end
  end

  context 'when url has no protocol prefix' do
    context 'when real protocol is https' do
      before do
        stub_request(:any, 'http://rubyonrails.org/assets/images/logo.svg').to_timeout
      end

      subject do
        FileDownloader.new(url: 'rubyonrails.org/assets/images/logo.svg', download_to: 'tmp')
      end

      let(:result) do
        VCR.use_cassette('file_downloader/https_missing') do
          subject.download
        end
      end

      it 'returns correct result' do
        expect(result).to eq :ok
      end

      it 'saves the image' do
        result
        expect(File.exist?('tmp/logo.svg')).to be true
        expect(FileUtils.compare_file('tmp/logo.svg', 'spec/fixtures/images/logo.svg')).to be true
      end
    end

    context 'when real protocol is http' do
      before do
        stub_request(:any, 'https://xinhuanet.com/2021homepro/images/logo.png').to_timeout
      end
      subject do
        FileDownloader.new(
          url: 'xinhuanet.com/2021homepro/images/logo.png',
          download_to: 'tmp'
        )
      end

      let(:result) do
        VCR.use_cassette('file_downloader/http_missing') do
          subject.download
        end
      end

      it 'returns correct result' do
        expect(result).to eq :ok
      end

      it 'saves the image' do
        result
        expect(File.exist?('tmp/logo.png')).to be true
        expect(
          FileUtils.compare_file('tmp/logo.png', 'spec/fixtures/images/logo.png')
        ).to be true
      end
    end
  end

  context 'when url has a redirect loop' do
    subject do
      FileDownloader.new(url: 'https://isup.me/redirect_loop.png', download_to: 'tmp')
    end

    let(:result) do
      VCR.use_cassette('file_downloader/redirect_loop') do
        subject.download
      end
    end

    it 'returns correct result' do
      expect(result).to eq :error
    end

    it 'does not save the image' do
      result
      expect(File.exist?('download/redirect_loop.png')).to be false
    end
  end

  context 'when file is too big' do
    subject do
      FileDownloader.new(url: 'https://rubyonrails.org/assets/images/huge.svg', download_to: 'tmp')
    end

    let(:result) do
      VCR.use_cassette('file_downloader/huge_file') do
        subject.download
      end
    end

    it 'returns correct result' do
      expect(result).to eq :error
    end

    it 'does not save the image' do
      result
      expect(File.exist?('download/huge.png')).to be false
    end
  end
end
