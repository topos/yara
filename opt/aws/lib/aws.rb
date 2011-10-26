require 'rake'

ENV['AWS_HOME'] = File.expand_path("#{File.dirname(__FILE__)}/..")
ENV['EC2_HOME'] = "#{ENV['AWS_HOME']}/opt/ec2"
ENV['S3_HOME'] = "#{ENV['AWS_HOME']}/opt/s3sync"

ENV['EC2_PRIVATE_KEY']= "#{ENV['AWS_HOME']}/etc/credentials/pk-KBA6I7HFKSR5IS2ESQKVFNJYCFWVA2PQ.pem"
ENV['EC2_CERT'] = "#{ENV['AWS_HOME']}/etc/credentials/cert-KBA6I7HFKSR5IS2ESQKVFNJYCFWVA2PQ.pem"

ENV['AWS_USER_ID'] = "470297622902"
ENV['AWS_ACCESS_KEY_ID'] = "AKIAIISKFGETLOZTVOBQ"
ENV['AWS_SECRET_ACCESS_KEY'] = "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"
ENV['SSH_KEY'] = "#{ENV['AWS_HOME']}/etc/credentials/id_law360-dev-keypair"

ENV['JAVA_HOME'] = (`uname` =~ /darwin/i) ? '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home' : "/usr/lib/jvm/java-6-sun"
ENV['PATH'] = "#{ENV['AWS_HOME']}/bin:#{ENV['EC2_HOME']}/bin:#{ENV['S3_HOME']}:#{ENV['PATH']}"

AWS_HOME = ENV['AWS_HOME']
ESSH = "#{AWS_HOME}/bin/essh"
ESCP = "#{AWS_HOME}/bin/escp"

# "_base" special cases for creating an AMI
AMI32_BASE = 'ami-e2af508b'
AMI64_BASE = 'ami-68ad5201'
# law360's prepackaged AMI
AMI32 = 'ami-7c0df515'
AMI64 = ''

# hackety-hack: change file mods--it's needed because git doesn't handle file mods
sh "chmod -R go-rwx #{File.expand_path(__FILE__ + '/../../etc/credentials')}/*"

# "_base" suffix is used to create an AMI image
def ami(type)
    case type
    when 'm1.small_base' then AMI32_BASE
    when 'm1.large_base' then AMI64_BASE
    when 'm1.small' || 'c1.medium' then AMI32
    else AMI64
    end
end

def ec2_info(instance_id)
    `ec2-describe-instances #{instance_id} | egrep '^INSTANCE'`.each_line do |l|
        info = l.split
        puts "#{info[1]}: #{info[13]} #{info[14]} #{info[3]} #{info[4]} #{info[8]}"
    end
end

def instance_id(ec2_output)
    ids = instance_ids(ec2_output)
    if 1 == ids.length
        ids[0]
    else
        raise "no instance ID or more than one in ec2_output: #{ec2_output}"
    end
end

def instance_ids(ec2_output)
    ids = []
    ec2_output.each_line do |l|
        ids << /INSTANCE(.+?)ami/.match(l)[1].strip if l =~ /^INSTANCE/
    end
    ids
end

def make_instance(args)
    args[:nodes] = 1 
    make_instances(args)
end

def make_instances(args ={})
    p = {:group => 'soc', :type => 'm1.small', :zone => 'us-east-1c', :nodes => 1, :ebs => 0, :key => 'law360-dev-keypair'}.merge(args)
    r = `ec2-run-instances #{ami p[:type]} --key #{p[:key]} --instance-type #{p[:type].split(/_/)[0]} --availability-zone #{p[:zone]} --group #{p[:group]} --instance-count #{p[:nodes]} -f #{ENV['AWS_HOME']}/lib/init_minimal.sh`.each_line.inject("") { |res, line| res + line }
    wait_for_instances(instance_ids r)
    r
end

def wait_for_instance(id)
    p = Proc.new {`ec2-describe-instances #{id} | egrep '^INSTANCE'`}
    while p.call.match('.*\.amazonaws\.com').nil? do
        warn "- waiting for ec2 instance, #{id}, to come up"
        sleep 3
    end
end

def wait_for_instances(ids)
    p = Proc.new {`ec2-describe-instances #{ids.join(' ')} | egrep '^INSTANCE'`}
    begin
        p.call.each_line do |l|
            raise if l.match('.*\.amazonaws\.com').nil?
        end
    rescue
        if ids.length > 1
            warn "- waiting for all ec2 instances to come up"
        else
            warn "- waiting for ec2 instance, #{ids[0]}, to come up"
        end
        sleep 3
        retry
    end
end

def ids2ips(ids)
    only_ids = ids.select { |id| id =~ /i\-[0-9a-f]+/ }
    ips = ids - only_ids
    if only_ids.length > 0
        `ec2-describe-instances #{only_ids.join(' ')} | egrep '^INSTANCE'`.each_line do |l|
            ips << l.split[13].strip
        end
    end
    ips
end

def id2ip(id)
    ids2ips([id])[0]
end

def extip2intip(extip)
    desc = `ec2-describe-instances | grep #{extip}`.split
    if desc.length > 14
        desc[14]
    else
        raise "no internal IP for external IP: #{extip}"
    end
end

def s3put(bucket, file)
    sh "#{ENV['AWS_ROOT']}/opt/s3sync/s3cmd.rb put #{bucket}:#{File.basename file} #{file}"
end

def s3get(bucket, file)
    sh "#{ENV['AWS_ROOT']}/opt/s3sync/s3cmd.rb get #{bucket}:#{File.basename file}"
end

def s3delete(bucket, file)
    sh "#{ENV['AWS_ROOT']}/opt/s3sync/s3cmd.rb delete #{bucket}:#{File.basename file}"
end

def s3list(bucket, file)
    sh "#{ENV['AWS_ROOT']}/opt/s3sync/s3cmd.rb list #{bucket}:#{file}"
end

def install_packages(ip)
    sh "essh ubuntu@#{ip} 'sudo add-apt-repository \"deb http://archive.canonical.com/ natty partner\"'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y remove mlocate'"
    #sh "essh ubuntu@#{ip} 'echo grub-pc grub2/linux_cmdline string | sudo debconf-set-selections'"
    #sh "essh ubuntu@#{ip} 'echo grub-pc grub-pc/install_devices_empty boolean true | sudo debconf-set-selections'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y update'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y safe-upgrade'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y remove mlocate'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y install ksh'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y install ruby'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y install gems'"
    sh "essh ubuntu@#{IP} 'sudo aptitude -y install libopenssl-ruby1.8'"
end

def install_java(ip)
    sh "essh ubuntu@#{ip} 'echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true | sudo debconf-set-selections'"
    sh "essh ubuntu@#{ip} 'sudo aptitude -y install sun-java6-jdk'"
    sh "essh ubuntu@#{ip} 'sudo update-java-alternatives -s java-6-sun || exit 0'"
    # install JVM security jars
    sh "essh ubuntu@#{ip} 'sudo rm -rf /tmp/jar'"
    sh "essh ubuntu@#{ip} 'mkdir -p /tmp/jar/security'"
    sh "escp *.jar ubuntu@#{ip}:/tmp/jar/security"
    sh "essh ubuntu@#{ip} 'sudo cp /tmp/jar/security/*.jar /usr/lib/jvm/java-6-sun/jre/lib/security/'"
end

def create_user(ip)
    sh "essh ubuntu@#{ip} \"[ id prod >/dev/null 2>&1 ] || sudo useradd -c \'Production User\' -d /home/prod -s /bin/bash -u 1010 -G sudo prod\""
    sh "essh ubuntu@#{ip} 'sudo mkdir -p /home/prod && sudo chown prod:prod /home/prod && sudo chmod 0755 /home/prod'"
    sh "essh ubuntu@#{ip} 'sudo mkdir -p /home/prod/.ssh && sudo chown prod:prod /home/prod/.ssh && sudo chmod 0755 /home/prod/.ssh'"
    sh "escp id_rsa.pub ubuntu@#{ip}:/tmp"
    sh "essh ubuntu@#{ip} 'sudo mv -f /tmp/id_rsa.pub /home/prod/.ssh'"
    sh "essh ubuntu@#{ip} 'sudo chown prod:prod /home/prod/.ssh/id_rsa.pub && sudo chmod 0644 /home/prod/.ssh/id_rsa.pub'"
    sh "essh ubuntu@#{ip} 'sudo cp /home/prod/.ssh/id_rsa.pub /home/prod/.ssh/authorized_keys'"
    sh "essh ubuntu@#{ip} 'sudo chown prod:prod /home/prod/.ssh/authorized_keys && sudo chmod 0644 /home/prod/.ssh/authorized_keys'"
end

def rsync(args ={})
    raise "missing :src or :dest" if args[:src].nil? || args[:dest].nil?
    args[:opts] = '' if args[:opts].nil?
    sh "rsync -av --rsh=essh --delete #{args[:opts]} #{args[:src]} #{args[:dest]}" 
end

def enable_daemon(daemon, ip)
    sh "essh ubuntu@#{ip} 'cd /etc/init && sudo mv -f #{daemon}.conf.disable #{daemon}.conf'"
end

def disable_daemon(daemon, ip)
    sh "essh ubuntu@#{ip} 'cd /etc/init && sudo mv -f #{daemon}.conf #{daemon}.conf.disable'"
end
