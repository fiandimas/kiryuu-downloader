# Kiryuu Downloader

Kiryuu Downloader is tool for automated download manga/manhwa. This tool only work on kiryuu.co website

### Usage
```sh
$ ruby main.rb {--url} {--start} {--end} {--output}
```

### Requirement

* Ruby 2.6.6
* Chromedriver 83.0.4103.39

## How To Use
1. Download and install [ruby 2.6.6](https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.6.tar.gz)
2. Download chrome driver [83.0.4103.39](https://chromedriver.storage.googleapis.com/index.html?path=83.0.4103.39/) and set path location to chromedriver.exe in environment variables.
3. Install selenium-webdriver with command "gem install selenium-webdriver"
4. Example usage:
```sh
$ cd kiryuu-downloader
$ ruby main.rb -h
$ ruby main.rb --url=https://kiryuu.co/manga/relife/ --start=1 --end=222 --output=D:\manga\ReLIFE
```

### Todos
* PDF output result every chapter
### License
MIT
