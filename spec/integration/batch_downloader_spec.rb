# frozen_string_literal: true

require 'rspec'
require './lib/batch_downloader'

describe BatchDownloader do
  before(:all) do
    FileUtils.mkdir_p('tmp')
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
    stdout_output = <<~STDOUT_OUTPUT
      Download started...
      Download finished!
    STDOUT_OUTPUT
    stderr_output = <<~STDERR_OUTPUT
      Cannot download https://rubyonrails.org/images/wrong.png
    STDERR_OUTPUT

    expect { result }.to output(stdout_output).to_stdout &
                         output(stderr_output).to_stderr_from_any_process
  end
end
