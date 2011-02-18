/*

== Class: tomcat::package::v5-5

Installs tomcat 5.5.X using your systems package manager.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed

Tested on:
- RHEL 5
- Debian Lenny

Usage:
  include tomcat::package::v5-5

*/
class tomcat::package::v5-5 inherits tomcat::package {

  case $operatingsystem {
    RedHat: {
      package { ["log4j", "jakarta-commons-logging"]: ensure => present }
    }
    Debian,Ubuntu: {
      package { ["liblog4j1.2-java", "libcommons-logging-java"]: ensure => present }
    }
  } 

  $tomcat = $operatingsystem ? {
    RedHat => "tomcat5",
    Debian => "tomcat5.5",
    Ubuntu => "tomcat5.5",
  }

  Package["tomcat"] {
    name   => $tomcat,
    before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  Service["tomcat"] {
    name    => $tomcat,
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => $operatingsystem ? {
      Debian => "-Dcatalina.base=/var/lib/tomcat",
      Ubuntu => "-Dcatalina.base=/var/lib/tomcat",
      RedHat => "-Dcatalina.base=/usr/share/tomcat",
    },
  }

  File["/etc/init.d/tomcat"] {
    path => "/etc/init.d/${tomcat}",
  } 

  case $operatingsystem {

    RedHat: {
      file { "/usr/share/tomcat5/bin/catalina.sh":
        ensure => link,
        target => "/usr/bin/dtomcat5",
      }

      User["tomcat"] {
        require => Package["tomcat5"],
      }
    }

    default: {
      err("operating system '${operatingsystem}' not defined.")
    }
  }

  file {"commons-logging.jar":
    path => $operatingsystem ? {
      RedHat  => "/var/lib/tomcat5/common/lib/commons-logging.jar",
      #Debian => TODO,
    },
    ensure => link,
    target => "/usr/share/java/commons-logging.jar", 
  }

  file {"log4j.jar":
    path => $operatingsystem ? {
      RedHat  => "/var/lib/tomcat5/common/lib/log4j.jar",
      #Debian => TODO,
    },
    ensure => link,
    target => $operatingsystem ? {
      /Debian|Ubuntu/ => "/usr/share/java/log4j-1.2.jar",
      RedHat          => "/usr/share/java/log4j.jar",
    },
  }

  file {"log4j.properties":
    path => $operatingsystem ? {
      RedHat  => "/var/lib/tomcat5/common/classes/log4j.properties",
      #Debian => TODO,
    },
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
    },
  }

}
