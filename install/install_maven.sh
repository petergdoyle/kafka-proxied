#!/bin/sh

maven_version='3.3.9'

eval 'mvn -version' > /dev/null 2>&1
if [ $? -eq 127 ]; then

  if [[ $EUID -eq 0 ]]; then
    maven_base='/usr/maven'
  else
    path='../../local/maven'
    mkdir -pv $path
    maven_base=$(readlink -f $path)
  fi
  maven_home="$maven_base/default"

  echo "downloading apache-maven-$maven_version..."
  #install maven
  curl -O http://www-us.apache.org/dist/maven/maven-3/$maven_version/binaries/apache-maven-$maven_version-bin.tar.gz \
    && tar -xvf apache-maven-$maven_version-bin.tar.gz -C $maven_base \
    && ln -s $maven_base/apache-maven-$maven_version $maven_home \
    && rm -f apache-maven-$maven_version-bin.tar.gz

  export MAVEN_HOME=$maven_home

  if [[ $EUID -eq 0 ]]; then

  alternatives --display java |grep -e '^/usr/maven/default/bin/mvn' > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    alternatives --install "/usr/bin/mvn" "mvn" "$maven_home/bin/mvn" 99999
    cat >/etc/profile.d/maven.sh <<-EOF
export MAVEN_HOME=$MAVEN_HOME
EOF
  fi

  else

    if ! grep -q MAVEN_HOME ~/.bash_profile; then
    cat >>~/.bash_profile <<-EOF
export MAVEN_HOME=$MAVEN_HOME
alias mvn=$MAVEN_HOME/bin/mvn
EOF
  fi

  fi

else
  echo -e "\e[7;44;96mapache-maven-$maven_version already appears to be installed. skipping."
fi
