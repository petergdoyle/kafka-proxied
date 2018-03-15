#!/bin/bash

parent_dir="$(dirname "$(pwd)")"
gradle_version='4.0.1'
if [[ $EUID -eq 0 ]]; then #check if run as root to determine where to install gradle
  gradle_base_location="/usr/maven"
else
  gradle_base_location=$parent_dir/local/maven
fi

eval 'mvn -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then
  mkdir /usr/maven
  #install maven
  curl -O http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
    && tar -xvf apache-maven-3.3.9-bin.tar.gz -C /usr/maven \
    && ln -s /usr/maven/apache-maven-3.3.9 /usr/maven/default \
    && rm -f apache-maven-3.3.9-bin.tar.gz
  alternatives --install "/usr/bin/mvn" "mvn" "/usr/maven/default/bin/mvn" 99999
  export MAVEN_HOME=/usr/maven/default
  cat >/etc/profile.d/maven.sh <<-EOF
export MAVEN_HOME=$MAVEN_HOME
EOF
else
  echo -e "\e[7;44;96mmaven already appears to be installed. skipping."
fi
