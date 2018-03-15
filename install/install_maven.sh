#!/bin/bash
. ../common.sh

java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  display_error "Jdk8 is not installed. Install Jdk8"
  exit 1
fi

maven_version='3.3.9'
eval 'mvn -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  maven_home="$local_maven_dir/default"

  echo "downloading apache-maven-$maven_version..."
  download_url=http://www-us.apache.org/dist/maven/maven-3/$maven_version/binaries/apache-maven-$maven_version-bin.tar.gz
  if [ ! -d $local_maven_dir ]; then
    mkdir -pv $local_maven_dir
  fi

  curl -O $download_url \
    && tar -xvf apache-maven-$maven_version-bin.tar.gz -C $local_maven_dir \
    && ln -s $local_maven_dir/apache-maven-$maven_version $maven_home \
    && rm -f apache-maven-$maven_version-bin.tar.gz

  export MAVEN_HOME=$maven_home

  if ! grep -q MAVEN_HOME ~/.bash_profile; then
    cat >>~/.bash_profile <<-EOF
export MAVEN_HOME=$MAVEN_HOME
export PATH=\$PATH:\$MAVEN_HOME/bin
EOF
    display_warn "$maven_version has been installed. Please source your ~/.bash_profile"
  fi

else
  display_info "apache-maven-$maven_version already appears to be installed. skipping."
fi
