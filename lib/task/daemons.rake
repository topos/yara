namespace :tomcat do
    desc "start tomcat"
    task :start do; sh "[ -d opt/tomcat/log ] || mkdir -p opt/tomcat/logs; opt/tomcat/bin/startup.sh"; end

    desc "stop tomcat"
    task :stop do
        sh "opt/tomcat/bin/shutdown.sh"
        sleep 1 if tomcat_pid
        while (pid = tomcat_pid) do
            sh "kill -9 #{pid}"
            sleep 1
        end
    end

    desc "restart tomcat"
    task :restart => [:stop, :start]

    desc "tail tomcat's log file"
    task :log do; sh "tail -100f opt/tomcat/logs/catalina.out"; end

    desc "version"
    task :info do; Dev.puts_color(`opt/tomcat/bin/version.sh`.each_line.map{|l| l.strip}); end

    def tomcat_pid
        `ps -eaf|grep java|egrep '\.Bootstrap[ ]+start$'|grep -v grep`.split[1]
    end
end

namespace :zk do
    desc "start zookeeper"
    task :start do; sh "opt/zookeeper/bin/zkServer.sh start"; end

    desc "stop zookeeper"
    task :stop do; sh "opt/zookeeper/bin/zkServer.sh stop"; end

    desc "restart zookeeper"
    task :restart do; sh "opt/zookeeper/bin/zkServer.sh restart"; end

    desc "zookeeper status"
    task :status do; sh "opt/zookeeper/bin/zkServer.sh status"; end

    desc "clean zookeeper: removes all state"
    task :clean do; sh "rm -rf /mnt/zookeeper/*"; end
end
