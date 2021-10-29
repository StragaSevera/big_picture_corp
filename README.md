# BatchDownloader

BatchDownloader is a command line tool for downloading images in bulk with parallel processing. It correctly handles errors and continues to download until all URLs were handled.

## Usage

Run `batch_download.sh <filename>` to download images listed in the file. The file should contain image URLs separated by whitespace.

The resulting images will be placed in `download` folder, creating one if it does not exist.