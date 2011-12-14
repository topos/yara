.PHONY: help dev mac apt_update mac_apt_install update_alt apt_clean gemrc gems buildr sun_java6

# bootstrap to get ruby and gem
help:; @echo "make dev: install packages needed for development on ubuntu 11.10"

dev: apt_update apt_install apt_clean gemrc gems buildr sun_java6

apt_update:; @sudo apt-get update

PKGS=build-essentials ksh m4 libprotoc6 ruby1.9.2-full xxdiff git
apt_install:; @for i in ${PKGS}; do sudo apt-get install -y $$i; done

apt_clean:
	@sudo apt-get autoremove
	@sudo apt-get autoclean

gemrc:;	echo 'gem: --no-ri --no-rdoc' >> ~/.gemrc

GEMS=rake smart_colored
gems:
	@for i in ${GEMS}; do \
		gem=$$(echo $$i|sed 's/:/ -v /1'); \
		echo $$gem; \
		if [ "$$(gem list --local -i $$gem)" = "false" ]; then sudo gem install --no-ri --no-rdoc $$gem; fi \
	done

buildr:
	@if [ "$$(gem list --local -i $@)" = "false" ]; then \
	    if [ -z "${JAVA_HOME}" ]; then \
	        sudo env JAVA_HOME=/usr/lib/jvm/java-6-sun gem install --no-ri --no-rdoc $@; \
	    else \
	        sudo gem install --no-ri --no-rdoc $@; \
	    fi; \
	fi

sun_java6:
	sudo apt-get install -y sun-java6-bin sun-java6-jdk sun-java6-jre sun-java6-fonts
	sudo update-java-alternatives --set java-6-sun || exit 0

ppa:
	sudo add-apt-repository ppa:ferramroberto/java
	sudo apt-get update -y
