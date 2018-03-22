#!/bin/bash
. ../common.sh

jdk_version='jdk-8u161'
java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  BASE_URL_8=http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/$jdk_version-linux-x64.tar.gz
  wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}"

  if [ ! -d $local_java_dir ]; then
    mkdir -pv $local_java_dir
  fi

  tar -xvf $jdk_version-linux-x64.tar.gz -C $local_java_dir \
    && ln -s $local_java_dir/jdk1.8.0_161/ $local_java_dir/default \
    && rm -f $jdk_version-linux-x64.tar.gz

    export JAVA_HOME=$local_java_dir/default

    if ! grep -q JAVA_HOME ~/.bash_profile; then
      cat >>~/.bash_profile <<-EOF
export JAVA_HOME=$JAVA_HOME
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
      display_warn "$jdk_version has been installed. Please source your ~/.bash_profile"
    fi

else

    display_info "$jdk_version already appears to be installed. skipping."

fi
