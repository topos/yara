namespace :image do
    desc "make an ami-image, e.g.: image[natty,x86_64], image[natty,i385]"
    task :make, [:image_name, :arch] do |t, args|
        IMG = args[:image_name]
        ARCH = args[:arch]
        TYPE = case ARCH
               when 'x86_64' then 'm1.large_base'
               when 'i386' then 'm1.small_base'
               else raise 'arch must be either "x86_64" or "i386"'
               end

        AWS_USER = ENV['AWS_USER_ID']
        AWS_KEYID = ENV['AWS_ACCESS_KEY_ID']
        AWS_SECRET = ENV['AWS_SECRET_ACCESS_KEY']

        PK = ENV['EC2_PRIVATE_KEY']
        PK_F = File.basename PK
        CERT = ENV['EC2_CERT']
        CERT_F = File.basename CERT

        ID = instance_id(make_instance(:type => TYPE))
        IP = id2ip(ID)

        IMG_NAME = "#{IMG}-#{ARCH}"

        # wait for sshd
        sleep 5
        begin
            sh "essh ubuntu@#{IP} 'sudo aptitude -y remove mlocate'"
        rescue
            sleep 3
            retry
        end

        install_packages IP
        install_java IP
        create_user IP

        sh "essh ubuntu@#{IP} 'sudo mkdir -p /mnt'"
        sh "escp #{PK} ubuntu@#{IP}:/tmp"
        sh "escp #{CERT} ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/*.pem /mnt'"

        sh "escp -r ../opt/ami ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/ami /opt'"

        sh "escp -r ../opt/ec2 ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/ec2 /opt'"

        sh "escp -r ../opt/s3sync ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/s3sync /opt'"
        File.open("/tmp/s3config.yml", "w") do |f|
            f.puts <<EOF
aws_access_key_id: #{ENV['AWS_ACCESS_KEY_ID']}
aws_secret_access_key: #{ENV['AWS_SECRET_ACCESS_KEY']}
EOF
        end
        sh "essh ubuntu@#{IP} 'sudo mkdir -p /etc/s3conf'"
        sh "escp /tmp/s3config.yml ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/s3config.yml /etc/s3conf'"
        sh "essh ubuntu@#{IP} 'sudo chown root:root /etc/s3conf/s3config.yml'"
        sh "essh ubuntu@#{IP} 'sudo chmod 0700 /etc/s3conf/s3config.yml'"

        sh "escp limits.conf ubuntu@#{IP}:/tmp"
        sh "essh ubuntu@#{IP} 'sudo mv -f /tmp/limits.conf /etc/security/'"

        sh "essh ubuntu@#{IP} \"EC2_HOME=/opt/ami sudo -E /opt/ami/bin/ec2-bundle-vol -d /mnt -k /mnt/#{PK_F} -c /mnt/#{CERT_F} -u #{AWS_USER} -r #{ARCH} -p #{IMG_NAME}\""
        sh "essh ubuntu@#{IP} \"EC2_HOME=/opt/ami sudo -E /opt/ami/bin/ec2-upload-bundle -b law360-ami -m /mnt/#{IMG_NAME}.manifest.xml -a #{AWS_KEYID} -s #{AWS_SECRET}\""
        sh "ec2-register -a #{ARCH} -n law360-ami/#{IMG_NAME} law360-ami/#{IMG_NAME}.manifest.xml"
    end
end

