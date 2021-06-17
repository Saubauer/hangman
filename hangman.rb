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
require "json"
require_relative "lib/classes"
require_relative "lib/modules"
include Basic

$main = Main.new

$main.start


