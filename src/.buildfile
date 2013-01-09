require "buildr/scala"
#require "buildr/java"

repositories.remote << "http://repo1.maven.org/maven2"
repositories.remote << "http://scala-tools.org/repo-releases/"

layout = Layout.new
layout[:source, :main, :java] = "../src/classes"
layout[:source, :main, :target] = "../lib/classes"
layout[:source, :main, :resources] = "../etc"

define "src" do
    define "classes" do
        # hack to handle scalac 2.9.0.1 stupidity: a lone "-g" breaks the compiler
    	compile.using :debug => false, :other => %w[-encoding utf-8 -g:vars], :target => '1.5'
        compile.with Dir[("../lib/jar/*.jar")]
        compile.with Dir[("#{ENV['TOMCAT_HOME']}/lib/servlet-api.jar")]
        compile.using(:scalac).from('classes').into('../lib/classes')
    end
end
