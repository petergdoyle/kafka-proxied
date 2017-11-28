#!/bin/sh
. ../kafka/common.sh

jdk_version='jdk-8u151'
java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  BASE_URL_8=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/$jdk_version-linux-x64.tar.gz
  wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}"
  if [ ! -d $local_java_dir ]; then
    mkdir -pv $local_java_dir
  fi

  tar -xvf $jdk_version-linux-x64.tar.gz -C $local_java_dir \
    && ln -s $local_java_dir/jdk1.8.0_151/ $local_java_dir/default \
    && rm -f $jdk_version-linux-x64.tar.gz

    export JAVA_HOME=$local_java_dir/default

    if ! grep -q JAVA_HOME ~/.bash_profile; then
    cat >>~/.bash_profile <<-EOF
export JAVA_HOME=$JAVA_HOME
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
    fi

else

    display_info "$jdk_version already appears to be installed. skipping."

fi
