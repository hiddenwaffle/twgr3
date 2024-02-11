namespace :admin do
  desc 'Interactively list all files in /Documents'
  task :list_documents do
    Dir['/Users/lysistrata/Documents/*'].each do |f|
      next unless File.file?(f)
      print "See #{f}?"
      answer = $stdin.gets
      case answer
      when /^y/
        puts 'Great, I am glad that you saw it'
      when /^q/
        break
      end
    end
  end
end
