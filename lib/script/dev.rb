module Dev
    DEV_HOME = File.expand_path("#{File.dirname(__FILE__)}/../..")

    def Dev.HOME; DEV_HOME; end

    def Dev.JAVA_HOME; ENV['JAVA_HOME'] || "/usr/lib/jvm/java-6-sun"; end

    def Dev.SCALA_HOME; "#{DEV_HOME}/opt/scala"; end

    def Dev.AWS_HOME; "#{DEV_HOME}/opt/aws"; end

    def Dev.TOMCAT_HOME; "#{DEV_HOME}/opt/tomcat"; end

    def Dev.ZOOKEEPER_HOME; "#{DEV_HOME}/opt/zookeeper"; end

    def Dev.CLASSPATH; classpath; end
    def Dev.SCALA_CLASSPATH; scala_classpath; end

    def Dev.scala(classname, argv =[])
        c = Dev.JAVA
        if classname != "" || classname != nil
            c << classname
            c << "-d #{Dev.HOME}/lib/classes"
            c << "-classpath #{Dev.CLASSPATH}"
        end
        c += argv unless argv.empty?
        c.join(" ")
    end

    def Dev.java(classname, argv =[])
        c = Dev.JAVA
        if classname != "" || classname != nil
            c << classname
        end
        c += argv unless argv.empty?
        c.join(" ")
    end

    def Dev.javac(argv)
        c = ["#{Dev.JAVA_HOME}/bin/javac"]
        c << "-J-Xms128m"
        c << "-J-Xmx512m"
        c << "-encoding UTF-8"
        c << argv
        c.join(" ")
    end

    RSYNC = "rsync -axv --copy-links --delete --delete-excluded --exclude '.git' --exclude '.gitignore' --exclude '*.scala' --exclude '*.java' --exclude '*.c' --exclude '*.cc' --exclude '*.m' --exclude '*.h'--exclude '*.m4' --exclude 'Rakefile' --exclude 'Makefile' --exclude 'logs/*' --exclude 'temp/*' --exclude 'work/*' --exclude '*.~*~' --exclude '#*'"

    def Dev.rsync(src, dst, opt ={:noop => true})
        if opt[:noop]
            puts "NOOP".red
            sh "#{RSYNC} --dry-run --rsh=#{ESSH} '#{src}' '#{dst}'"
        else
            sh "#{RSYNC} --rsh=#{ESSH} '#{src}' '#{dst}'"
        end
    end

    def Dev.classpath
        p = ["#{DEV_HOME}/etc", "#{DEV_HOME}/etc/properties", "#{DEV_HOME}/lib/classes"]
        p << Dir["#{DEV_HOME}/lib/jar/**/*"]
        p << "#{Dev.TOMCAT_HOME}/lib/servlet-api.jar"
        p.join(":")
    end

    def Dev.file2class(file)
        es = file.split(/\/|\./)
    end

    def Dev.scala_classpath
        Dir["#{Dev.SCALA_HOME}/lib/**/*"].join(":")
    end

    def Dev.bits
       case `uname -m`.strip
       when "x86_64"
           "-d64"
       else
           ""
       end
    end

    def Dev.JAVA
        c = ["#{Dev.JAVA_HOME}/bin/java"] 
        c << Dev.bits if Dev.bits
        c << "-cp " + [Dev.scala_classpath, Dev.classpath].join(":")
        c << "-Dscala.home=#{Dev.SCALA_HOME}"
        c << "-Djava.net.preferIPv4Stack=true"
        c
    end
end

JAVA_HOME = Dev.JAVA_HOME
ENV['JAVA_HOME'] = Dev.JAVA_HOME

SCALA_HOME = Dev.SCALA_HOME
ENV['SCALA_HOME'] = Dev.SCALA_HOME

TOMCAT_HOME = Dev.TOMCAT_HOME
ENV['TOMCAT_HOME'] = Dev.TOMCAT_HOME

JAVA = "#{Dev.JAVA_HOME}/bin/java"
SCALA_RUNNER = 'scala.tools.nsc.MainGenericRunner'

PROJ_NAME = '_NAME_'

ENV['PATH'] = "#{Dev.HOME}/bin:#{ENV['PATH']}"
