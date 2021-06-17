module Basic
  def dict_cleaning(filename)
    return 'Error' unless File.exist?(filename)

    dict = File.open(filename)
    wordlist = []

    dict.each do |line|
      line.gsub!("\n", '')
      wordlist.push(line.downcase) if line.length > 4 && line.length < 13
    end

    File.open('wordlist.txt', 'w') do |file|
      file.write(wordlist.join("\n"))
    end
    dict.close
  end

  def cls
    system('cls') || system('clear')
  end
end
