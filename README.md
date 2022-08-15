# BatchDownloader

BatchDownloader is a command line tool for downloading images in bulk with parallel processing. It correctly handles errors 
and continues to download until all URLs are handled.

## Installation

After checking out the repository, run `bundle install`.

## Usage

Run `./batch_download.sh <filename>` to download images listed in the file. The file should contain image URLs separated by 
whitespace.

The resulting images will be placed in `download` folder, creating one if it does not exist.

## Testing

Run `bundle exec rspec`.