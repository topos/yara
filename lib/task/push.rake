namespace :push do
    require File.expand_path("#{File.dirname(__FILE__)}/../script/dev")

    desc "push app to PROD"
    task :prod do
    end

    desc "push app to QA"
    task :qa do
    end

    desc "push app to [hostname/IP], e.g.: \"rake qa\" followed by \"rake push[<IP>]\""
    task :dist, :ip, :yes? do |t, args|
        sh "#{ESSH} #{args[:ip]} 'sudo mkdir -p /mnt/dist && sudo chown -R ubuntu /mnt/dist'"
        Dev.rsync(Dev.TOMCAT_HOME, "#{args[:ip]}:/mnt/dist/", :noop => args[:yes?] == "[Yy]{1,1}[Ee]{1,1}[Ss]{1,1}")
        sh "#{ESSH} #{args[:ip]} 'sudo rsync -ax --delete /mnt/dist/tomcat/ /opt/tomcat/'"
    end
end
