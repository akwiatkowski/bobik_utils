require 'optparse'

options = { }
OptionParser.new do |opts|
  opts.banner = "Usage: bobik_audio_converter.rb -f FROM -t TO"

  opts.on("-f", "--from FROM", "Input type") do |v|
    options[:from] = v
  end
  opts.on("-t", "--to TO", "Output type") do |v|
    options[:to] = v
  end
  opts.on("-c", "--clean", "Clean duplicated file using only filename") do |v|
    puts "find . -iname \"*(1)*\" -exec rm {} \;"
    puts "find . -iname \"*(2)*\" -exec rm {} \;"
    return
  end
end.parse!

def search_files(ext)
  Dir["**/*.#{ext}"]
end

def replace_ext(file, new_ext)
  file.gsub(/\.\w+$/, ".#{new_ext}")
end

# File extension
def ext(file)
  file[/\.(\w+)$/].gsub(/^\./, '').downcase
end

def decode(file)
  case ext(file)
    when 'wtf' then
      puts "Wtf man ;)"
    # musepack library is currently fucked up on my pc
    #when 'mpc' then
    #  decode_musepack(file)
    else
      decode_using_mplayer(file)
    #puts "#{ext(file)} is not supported"
  end
end

def decode_musepack(file)
  output = replace_ext(file, "wave").gsub(/,/, '_')
  # should work, but i had fucked up decoding libraries
  puts "mpcdec -i \"#{file}\" \"#{output}\""
end

def decode_using_mplayer(file)
  output = replace_ext(file, "wave").gsub(/,/, '_')
  puts "mplayer \"#{file}\" -ao pcm:file=\"#{output}\""
end

def encode(file, ext)
  case ext
    when 'ogg' then
      encode_ogg(file)
    when 'flac' then
      encode_flac(file)
    else
      puts "#{ext(file)} is not supported"
  end
end

def encode_ogg(file, quality = 4)
  temp = replace_ext(file, "wave").gsub(/,/, '_')
  output = replace_ext(file, "ogg").gsub(/,/, '_')
  puts "oggenc -q#{quality} \"#{temp}\" -o \"#{output}\""
end

def encode_flac(file, quality = 8)
  temp = replace_ext(file, "wave").gsub(/,/, '_')
  #output = replace_ext(file, "flac").gsub(/,/, '_')
  puts "flac -#{quality} \"#{temp}\""
end

def remove_tmp(file)
  output = replace_ext(file, "wave").gsub(/,/, '_')
  puts "rm \"#{output}\""
end

def move_to_other_location(file, ext)
  dir = file.gsub(/[^\/]+$/, '')
  output = replace_ext(file, ext).gsub(/,/, '_')
  puts "mkdir -p \"1DONE/#{dir}\""
  puts "mv \"#{output}\" \"./1DONE/#{dir}/\""
end

if options[:from] and options[:to]
  search_files(options[:from]).sort.each do |f|
    puts "\n# --- #{f}"
    decode(f)
    encode(f, options[:to])
    remove_tmp(f)
    move_to_other_location(f, options[:to])
  end
end

