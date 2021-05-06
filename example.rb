def main
  for i in 0...5
    puts i
    if(i == 3)
      STDOUT.flush
      gets
    end
  end
end

main()
