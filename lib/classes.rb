#################################################################
class Display
	def self.intro
		cls
		puts "Hangman Game
		"
		puts "Computer chooses a random word from a dictonary "
		puts "and you have 8 changes to guess the word correctly
		"
		puts "(Press any key to continue)"
		gets 
		cls
	end

	def self.goodbye
		cls
		puts "Thanks for playing Hangman"
		sleep(2)
		cls
	end
	def self.guess(guess, word, wrong=[], mistake)
		cls
		puts "You guessed: '#{guess.upcase}'
		" unless guess == "";
		puts "Word: #{word.join("")}
		"
		puts "Wrong guesses: #{wrong.join("")}" unless wrong.empty?
		puts "and mistakes: #{mistake} / 8
		" unless mistake == 0
	end

	def self.game_end(win, word)
		puts ""
		puts "You won!" if win == 1
		puts "You lose!" if win == 0
		puts ""
		puts "Word was: #{word.join("")}"
		gets
	end
end
#################################################################
class Game
	def initialize(mistakes=0,correctWord=0,wrongGuesses=[],guessWord=[])
		dict_cleaning("5desk.txt") unless File.exists?("wordlist.txt")
		if correctWord == 0 then
			@correctWord = random_word.split("") 
		else
			@correctWord = correctWord
		end
		if guessWord.empty? then
			@guessWord = Array.new(@correctWord.length,"_")
		else
			@guessWord = guessWord
		end	
		@wrongGuesses = wrongGuesses
		@mistakes = mistakes
	end

	def random_word
		File.open("wordlist.txt") do |file|
			file.readlines.sample.gsub!("\n","")
		end
	end

	def new_game
		puts "Word: #{@guessWord.join("")}
		"
		guessing
	end

	def guessing 
		until @mistakes == 8 || @guessWord == @correctWord do 
			guess = make_guess
			return game_save if guess == "save"
			check_guess(guess)
			Display.guess(guess,@guessWord,@wrongGuesses,@mistakes)
		end

		if @mistakes == 8 then
			Display.game_end(0, @correctWord)
			$main.start
		else
			Display.game_end(1, @correctWord)
			$main.start
		end
	end

	def make_guess
		puts "Enter single letter or 'save'"
		input = gets.chomp

		return input if input == "save"
		return input if input.length == 1 && input.match?(/[a-z]/) && @guessWord.none?(input) && @wrongGuesses.none?(input)
		puts "Either you chose a letter you already had before or entered an invalid input"
		make_guess

	end

	def check_guess(guess)
		if @correctWord.include?(guess) then
			@correctWord.each_with_index {|letter,index|
				@guessWord[index] = letter if letter == guess
			}
		else
			@mistakes += 1
			@wrongGuesses.push(guess)
		end
	end

	def game_save
		Dir.mkdir('sav') unless Dir.exist?('sav')
		save = JSON::dump({
	      	:mistakes => @mistakes,
	      	:correctWord => @correctWord,
	      	:wrongGuesses => @wrongGuesses,
	      	:guessWord => @guessWord
    	})
		puts "Enter save name"
		savename = gets.chomp

		filename = "sav/#{savename}.json"
		File.open(filename, 'w') do |file|
			file.puts save
		end
		$main.start
	end

	def game_load
		Display.guess("",@guessWord,@wrongGuesses,@mistakes)
		new_game
	end
end
#################################################################
class Main
	def initialize
		@game = nil 
	end

	def start
		cls
		puts "Do you want to start a new game, load a old game or quit?
		"
		puts "Enter either 'n' or 'new' for new game 'load' or 'l' for load or anything else to quit"

		input = gets.chomp

		if input.downcase == "n" || input.downcase == "new" then 
			new_game
		elsif input.downcase == "load" || input.downcase == "l" then
			game_load
		else
			Display.goodbye
		end
	end

	def new_game
		@game = Game.new
		Display.intro
		@game.new_game
	end

	def game_load
		cls
		@save = nil
		puts "Enter save name"
		savename = gets.chomp

		filename = "sav/#{savename}.json"
		if File.exist?(filename) then
		File.open(filename, 'r') do |file|
			@save = file.read
		end
		else
			puts "File doesn't exist"
			sleep(1)
			start
		end
		
		data = JSON.load @save
		@game = Game.new(data['mistakes'], data['correctWord'], data['wrongGuesses'], data['guessWord'])
		@game.game_load
	end
end