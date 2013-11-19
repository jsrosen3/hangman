class Hangman
  attr_accessor :num_wrong_guesses, :guessed_letters, :progress

  def initialize
    @guesser = play_mode("guesser")
    @word_selector = play_mode("word selector")
    @num_wrong_guesses = 0
    @guessed_letters = []
    @progress = []
  end

  def play_mode(string)
    puts "Who is the #{string}? Enter H for human or C for computer."
    print "> "
    player = initialize_player(gets.chomp)
  end

  def initialize_player(choice)
    if choice.downcase == "h"
      player = HumanPlayer.new
    else
      player = ComputerPlayer.new
    end
    player
  end

  def play
    word_length = @word_selector.pick_word
    @progress = ["_"] * word_length
    until @num_wrong_guesses >= 10
      letter = @guesser.guess(@progress, @guessed_letters, @num_wrong_guesses)
      @guessed_letters << letter
      indices = @word_selector.check(letter)
      if indices == []
        @num_wrong_guesses += 1
        next
      end
      update_progress(letter, indices)
      unless @progress.include?('_')
        @guesser.class == HumanPlayer ? winner = "Human" : winner = "Computer"
        puts "#{winner} wins! The word was '#{@progress.join}.'"
        return
      end
    end
    @word_selector.class == HumanPlayer ? winner = "Human" : winner = "Computer"
    print "#{winner} wins! "
    puts "The word was '#{@word_selector.word.join}'." if @word_selector.class == ComputerPlayer
    puts ""
  end

  def update_progress(letter, indices)
    indices.each { |index| @progress[index] = letter}
  end
end

class HumanPlayer

  def pick_word
    puts "Please think of a word. No plural words, please."
    puts "How long is your word?"
    print "> "
    word_length = gets.chomp.match(/\d+/).to_s.to_i
  end

  def guess(progress, guessed_letters, num_wrong_guesses)
    puts "You have #{10 - num_wrong_guesses} wrong guesses left."
    puts "Secret word: #{progress.join(" ")}"
    print "> "
    guess = gets.chomp
    while guessed_letters.include?(guess)
      puts "You've already guessed that letter. Please choose another."
      print "> "
      guess = gets.chomp
    end
    guess
  end

  def check(guess)
    puts "Enter the indices of the location of '#{guess}' in your word. Enter 'wrong' if the guess was incorrect"
    indices = gets.scan(/\d/)
    indices.map! { |index| index.to_i - 1 } # Humans typically start counting at 1 but arrays are indexed at 0
    indices
  end
end

class ComputerPlayer
  attr_accessor :word

  def initialize
    @dictionary = File.read("./dictionary.txt").split("\n")
  end

  def pick_word
    ok_words = @dictionary.select { |word| word.length > 6 and !word.include?('\'') and !word.include?('-')}
    @word = ok_words.sample.chomp.split('')
    @word.length
  end

  def guess(progress, guessed_letters, num_wrong_guesses)
    puts "Computer has #{10 - num_wrong_guesses} wrong guesses left."
    puts "\n" + progress.join(' ')
    puts "\n"
    possible_word_list ||= words_of_correct_length(progress)
    possible_word_list = possible_words(possible_word_list, progress)
    guess = most_common_letter(possible_word_list, guessed_letters)
    guess
  end

  def check(guess)
    indices = []
    @word.each_with_index { |letter, i| indices << i if guess == letter }
    indices
  end

  def words_of_correct_length(progress)
    @dictionary.select { |word| word.length == progress.length }
  end

  def possible_words(possible_word_list, progress)
    progress.each_with_index do |char, index|
      if char == '_'
        next
      end
      possible_word_list.delete_if { |word| char != word[index] }
    end
    possible_word_list
  end

  def most_common_letter(possible_word_list, guessed_letters)
    letters = possible_word_list.join.split('')
    letter_count_hash = Hash.new(0)
    letters.each { |letter| letter_count_hash[letter] += 1 }
    letter_frequencies = letter_count_hash.sort_by { |key, value| value }.reverse
    letter_frequencies.each do |letter_and_frequency|
      letter = letter_and_frequency[0]
      return letter if !guessed_letters.include?(letter)
    end
  end
end

hangman = Hangman.new
hangman.play