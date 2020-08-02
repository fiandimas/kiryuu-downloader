require 'open-uri'
require 'selenium-webdriver'
require 'uri'

def xpath_url_chapter(id, i)
    return "//*[@id='post-#{id}']/div[2]/ul/li[#{i}]/span[1]/a"
end

def xpath_image
    return '//img[@class="alignnone size-full wp-image-72251"]'
end

def in_range(v, s, e)
    return v.to_i.between?(s.to_i, e.to_i)
end

def parse_integer(s)
    return s.delete('^0-9').to_i
end

def is_integer(s)
    return s.to_i.to_s == s
end

def valid_kiryuu(s)
    uri = URI.parse(s)
    return uri.host == 'kiryuu.co'
end

HELP = <<ENDHELP
Usage:
   ruby main.rb [-h] [-u] [-s] [-e] [-o]
    -h, --help       Show this help.
    --url        Manga url.
    --start      Start chapter.
    --end        End Chapter.
    --output     The folder output.
ENDHELP

args = Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/)]

ARGV.each do |arg|
  case arg
    when '-h','--help'      then args["help"]      = true
  end
end

if args["help"]
    puts HELP
    return
end

manga_url = args["url"]
start_chapter = args["start"]
last_chapter = args["end"]
dest = Dir.pwd

if manga_url.nil? || start_chapter.nil? || last_chapter.nil?
    raise 'required arg is missing. use -h or --help command to see args'
end

if valid_kiryuu(manga_url) == false
    raise 'given url is invalid'
end

if is_integer(start_chapter) == false || is_integer(last_chapter) == false
    raise 'given chapter is invalid'
end

if parse_integer(start_chapter) > parse_integer(last_chapter)
    raise 'invalid chapter. start chapter must be lower than last chapter'
end

if args["output"].nil? == false
    dest = args["output"]

    if File.exists?(dest) == false
        raise 'destination path must be valid path. or leave it empty'
    end
end

options = {
        args: ['headless', 'disable-gpu', 'disable-notifications', 'log-level=3'],
        w3c: true,
        mobileEmulation: {},
        prefs: {
            :protocol_handler => {
                :excluded_schemes => {
                    tel: false
            }
        }
    }
}

caps = Selenium::WebDriver::Chrome::Options.new(options: options)

driver = Selenium::WebDriver.for(:chrome, options: caps)

driver.get manga_url

id = parse_integer(driver.find_element(:xpath => '/html/head/link[9]').attribute('href'))

links = []

driver.find_elements(:class => 'lchx').each.with_index { |v, i|
    element_chapter_url = driver.find_element(:xpath => xpath_url_chapter(id, i+=1))

    chapter_url = element_chapter_url.attribute('href')
    
    if (in_range(parse_integer(chapter_url), start_chapter, last_chapter))
        links.push({
            :chapter => element_chapter_url.text,
            :chapter_url => chapter_url
        })
    end
}

links.reverse!

links.each { |l|
    puts "downloading #{l[:chapter]} ..."

    driver.navigate.to l[:chapter_url]
    
    driver.find_elements(:xpath => xpath_image()).each.with_index{ |e, i| 
        src = e.attribute('src')

        open(src) { |f|
            ext = src.split('.').last()
            chapter = l[:chapter]

            path = File.join(dest, chapter)

            Dir.mkdir(path) unless File.exists?(path)

            File.open("#{path}/#{i}.#{ext}", 'wb') do |file|
                file.puts f.read
            end
        }
    }
}

puts 'success download'
