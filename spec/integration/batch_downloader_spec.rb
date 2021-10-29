# frozen_string_literal: true

require 'rspec'
require './lib/batch_downloader'

describe BatchDownloader do
  before(:all) do
    Dir.mkdir('tmp') unless File.exist?('tmp')
  end

  around(:each) do |example|
    old_files = Dir.entries('tmp').to_set
    example.run
  ensure
    new_files = Dir.entries('tmp').to_set
    (new_files - old_files).each { |filename| File.delete("tmp/#{filename}") }
  end

  subject { BatchDownloader.new(filename: 'spec/fixtures/images/image_list.txt', download_to: 'tmp') }

  let(:result) do
    VCR.use_cassette('batch_downloader/default') do
      subject.download
    end
  end

  it 'downloads correct amount of files' do
    old_files_amount = Dir.entries('tmp').count
    result
    new_files_amount = Dir.entries('tmp').count
    expect(new_files_amount - old_files_amount).to eq 4
  end

  it 'outputs correct messages' do
    correct_output = <<~OUTPUT
      Download started...
      Cannot download https://rubyonrails.org/images/wrong.png
      Download finished!
    OUTPUT

    expect { result }.to output(correct_output).to_stdout
  end
end
