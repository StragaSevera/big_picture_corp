# frozen_string_literal: true

require 'rspec'
require './lib/batch_downloader'

describe BatchDownloader do
  around(:each) do |example|
    old_files = Dir.entries('download').to_set
    example.run
    new_files = Dir.entries('download').to_set

    (new_files - old_files).each { |filename| File.delete("download/#{filename}") }
  end

  subject { BatchDownloader.new('spec/fixtures/images/image_list.txt') }

  let(:result) do
    VCR.use_cassette('batch_downloader/default') do
      subject.download
    end
  end

  it 'downloads correct amount of files' do
    old_files_amount = Dir.entries('download').count
    result
    new_files_amount = Dir.entries('download').count
    expect(new_files_amount - old_files_amount).to eq 3
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
