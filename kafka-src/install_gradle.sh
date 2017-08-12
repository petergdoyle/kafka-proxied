#!/bin/sh

parent_dir="$(dirname "$(pwd)")"
gradle_version='4.0.1'
if [[ $EUID -eq 0 ]]; then #check if run as root to determine where to install gradle
  gradle_base_location="/usr/gradle"
  profile_d="/etc/profile.d/gradle.sh"
else
  gradle_base_location="$parent_dir/local/gradle"
  profile_d="/etc/profile.d/gradle.sh"
fi
if [ ! -d "$gradle_base_location/gradle-$gradle_version" ]; then
  mkdir -pv $gradle_base_location \
  && echo "downloading gradle-$gradle_version..."

  curl -OL "https://services.gradle.org/distributions/gradle-$gradle_version-bin.zip" \
  && unzip gradle-$gradle_version-bin.zip -d $gradle_base_location \
  && rm -fv gradle-$gradle_version-bin.zip \
  && ln -s $gradle_base_location/gradle-$gradle_version $gradle_base_location/default

  export GRADLE_HOME=$gradle_base_location/default
  cat >$profile_d <<-EOF
export GRADLE_HOME=$GRADLE_HOME
EOF

  # register all the java tools and executables to the OS as executables
  install_dir="$GRADLE_HOME/bin"
  for each in $(find $install_dir -executable -type f) ; do
    name=$(basename $each)
    alternatives --install "/usr/bin/$name" "$name" "$each" 99999
  done

else
  echo -e "\e[7;44;96m*$gradle_version already appears to be installed. skipping.\e[0m"
fi
