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
    when 'mpc' then
      decode_musepack(file)
    else
      puts "#{ext(file)} is not supported"
  end
end

def decode_musepack(file)
  output = replace_ext(file, "wave")
  # should work, but i had fucked up decoding libraries
  #puts "mpcdec -i \"#{file}\" \"#{output}\""
  puts "mplayer \"#{file}\" -ao pcm:file=\"#{output}\""
end

def encode(file, ext)
  case ext
    when 'ogg' then
      encode_ogg(file)
    else
      puts "#{ext(file)} is not supported"
  end
end

def encode_ogg(file)
  temp = replace_ext(file, "wave")
  output = replace_ext(file, "ogg")
  puts "oggenc -q10 \"#{temp}\" -o \"#{output}\""
end

def remove_tmp(file)
  output = replace_ext(file, "wave")
  puts "rm \"#{output}\""
end

search_files("mpc").sort.each do |f|
  puts "\n# --- #{f}"
  decode(f)
  encode(f, "ogg")
  remove_tmp(f)
end