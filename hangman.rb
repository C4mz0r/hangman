require 'colorize'
require 'yaml'

class Hangman

  @@MAXWRONGGUESSES = 5	

	def initialize
		@incorrect_count = 0		
		@guessed = []
		@word_to_guess = chooseRandomWord.downcase
		@word_to_display = "_" * @word_to_guess.length 
	end

	def gameLoop		
		loop do
			display
			getGuess
			break if won? or lost?
		end	
		gameOver
	end

	private

			def display
				puts "You have guessed #{@incorrect_count} / #{@@MAXWRONGGUESSES} incorrectly."
				puts "You have guessed the following letters: #{@guessed}"
				puts @word_to_display.split("").join(" ")
				drawGuy
			end

			def drawGuy	
				if (@incorrect_count == 1)
					puts " O ".colorize(:blue)				
				elsif (@incorrect_count == 2)
					puts " O ".colorize(:blue)
					puts " | ".colorize(:blue)
				elsif (@incorrect_count == 3)
					puts " O ".colorize(:blue)
					puts "-| ".colorize(:blue)
				elsif (@incorrect_count == 4)
					puts " O ".colorize(:blue)
					puts "-|-".colorize(:blue)
				elsif (@incorrect_count == 5)
					puts " O ".colorize(:blue)
					puts "-|-".colorize(:blue)
					puts "/".colorize(:blue)
				elsif (@incorrect_count >= 5)
					puts " O ".colorize(:blue)
					puts "-|-".colorize(:blue)
					puts "/ \\".colorize(:blue)
				end
			end			

			# get a letter from the user
			def getGuess
				puts "Enter your next guess:"
				guess = gets.chomp.downcase
				processGuess(guess)
			end

			# if the word doesn't include the guess, then the incorrect count increases
			# otherwise the word to display to the user gets updated
			def processGuess(guess)
				if guess == "save"
					serialized_object = YAML::dump(self)
					#DEBUG					
					puts serialized_object
					File.open("save.yml", "w") { |file| file.write(serialized_object) }
					return				
				end

				if @guessed.include?guess 
					puts "You already guessed that letter!  Try choosing one that you haven't selected before!"
					return				
				end

				@guessed << guess
				if @word_to_guess.include?guess
					@word_to_display = maskWord( @word_to_guess, @guessed, "_" )
				else
					@incorrect_count += 1
				end
			end

		# Choose a random word between 5 and 12 characters long
		# Not sure if the dictionary contains umlauted characters, etc. so to be safe, only allow words that are comprised of A-Z or a-z
		def chooseRandomWord
			file = File.open("5desk.txt", "r")
			words = file.readlines
			possibleWord = nil
			loop do
				randomWordNumber = rand(0...words.size)
				possibleWord = words[randomWordNumber].chomp
				break if possibleWord.length >= 5 and possibleWord.length <= 12 and !!(/^[a-zA-Z]+$/ =~ possibleWord)
			end
			possibleWord
		end

		# Mask a word based on users guesses
		# e.g. if word is turkey and user guesses is [t,y] then it would return t****y
		def maskWord (word, guesses, mask_character)
			maskedWord = mask_character * word.length
			for i in (0...word.length)
				if guesses.include?word[i].downcase then 
					maskedWord[i] = word[i]
				end
			end
			maskedWord
		end

		# game over - let the user know if he/she won or lost
		def gameOver
			if won?
				puts "Congratulations!  You guessed the secret word!".colorize(:green)
			else
				drawGuy				
				puts "Oops!  Too bad, you didn't get it this time!  The word we were looking for was #{@word_to_guess}.".colorize(:red)
			end
		end

		# check if the user has guessed the secret word properly
		def won?
			return @word_to_guess.downcase == @word_to_display.downcase
		end

		# check if the user has lost the game (i.e. too many incorrect guesses)
		def lost?
			return @incorrect_count > @@MAXWRONGGUESSES
		end

    # Class Methods:

		# introduction screen
		def self.greetings
			puts "Welcome to Hangman!"
			puts "A secret word will be chosen and you'll need to guess one letter at a time."
			puts "You can make up to #{@@MAXWRONGGUESSES} mistakes, but after that it's game over!"
		end

    # return a deserialized hangman object if specified (nil if not)
		def self.promptForLoad
      self.greetings
		  puts "Would you like to load the saved game? [y/n]"
	    answer = gets.chomp.downcase
	    if answer == 'y'		
		    file = File.open("save.yml", "r")
		    return YAML.load(file)
  	  end
    end

end

h = Hangman.promptForLoad || Hangman.new
h.gameLoop
