YARA_HOME = File.expand_path(File.dirname(__FILE__))
Dir.glob("#{YARA_HOME}/lib/task/*.rake").each { |r| import r }

require 'smart_colored/extend'

task :default do; sh "rake -T"; end

desc "info scala and java versions"
task :info do
    ["#{Dev.SCALA_HOME}/bin/scala -version||exit 0", "#{Dev.JAVA_HOME}/bin/java -version 2>&1"].each do |c|
        `#{c}`.each_line.map{|l| l.strip}.each do |l|
            puts case l 
            when /^Scala code.*/; l.green
            when /java version.*/; l.red
            else; l
            end
        end
    end
end

desc "make a distribution for QA"
task :qa => :build do; sh "cd etc && rake clean qa"; end
task :staging => :qa

desc "make a distribution for PROD"
task :prod => :build do; sh "cd etc && rake clean prod"; end

task :ccc do; sh "cd src && rake ccc"; end
task :cc do; sh "cd src && rake cc"; end

