class Cursor
  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  case input_char
  when "\r" #RETURN
    board.reveal_tile(*coord)
  when " "
    board.flag_tile(*coord)
  when "\e"
    puts "Are you sure you want to exit the game? (y/n)"
    if gets.chomp == "y"
      exit
    end
  when "\e[A" #up arrow
    board.move_cursor("up")
  when "\e[B" #down
    board.move_cursor("down")
  when "\e[C" #right
    board.move_cursor("right")
  when "\e[D" #left
    board.move_cursor("left")
  when "s"
    save_game
  when "l"
    load_game
  when "\u0003"
    puts "CONTROL-C"
    exit 0
  else
  end
end
