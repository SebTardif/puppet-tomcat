class tomcat::package::v7 {
notify {"class $name is deprecated, class 'tomcat' is automatically included for backwards compatibility":}
include tomcat
}