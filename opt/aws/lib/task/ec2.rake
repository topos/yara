require 'rubygems'
require 'smart_colored/extend'

namespace :ec2 do
    # :type = m1.{small,large,xlarge} or c1.{medium,xlarge}
    desc "make an ec2 instance, defaults: [soc, m1.small, us-east-1c, 1, 0]"
    task :make, [:group, :type, :zone, :nodes, :ebs] do |t, args|
        id = instance_id(make_instance(args))
        puts "instance ID=" + "#{id}".green
        wait_for_instance(id)
        puts "rake ec2:ssh[#{id}]".green
    end

    desc "ssh to an instance using either an ID, IP, or host name with optional <cmd>"
    task :ssh, :hostid, :cmd do |t, args|
        if args[:cmd].nil?
            sh "essh ubuntu@#{id2ip(args[:hostid])}"
        else
            sh "essh ubuntu@#{id2ip(args[:hostid])} '#{args[:cmd]}'"
        end
    end

    desc "reboot an instance"
    task :reboot, :instance_id do |t, args|
        raise "missing instance ID" if args[:instance_id].nil?
        sh "ec2-reboot-instances #{args[:instance_id]}"
    end

    desc "kill an instance"
    task :kill, :instance_id do |t, args|
        raise "missing instance ID" if args[:instance_id].nil?
        sh "ec2-terminate-instances #{args[:instance_id]}"
    end

    desc "list instances"
    task :list do
        now = DateTime.now
        `ec2-describe-instances`.each_line do |l|
            e = l.split(/\s+/)
            next if e[0] == "RESERVATION" or e.size < 19
            d = DateTime.parse(e[9])
            delta = now - d
            h, m, s, f = Date.day_fraction_to_time(delta)
            p "#{e[13]} (#{e[14]})\t#{e[1]}\t#{e[8]}\t#{h} h (#{delta.to_i} d)\t#{e[9]} (#{e[10]})"
        end
    end

    desc "ec2-describe instances"
    task :describe do
        sh "ec2-describe-instances"
    end

    desc "shows information about a single instance"
    task :info, :instance_id do |t, args|
        ec2_info(args[:instance_id])
    end
end
