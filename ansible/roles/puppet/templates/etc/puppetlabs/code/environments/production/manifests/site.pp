file {'/tmp/it_works.txt':                        # resource type file and filename
  ensure  => present,                             # make sure it exists
  mode    => '0644',                              # file permissions
  content => "It works on ${ipaddress_enp0s8}!\n",  # Print the enp0s8 fact
}

group { 'jet':
  ensure  => present,
  gid     => '10000',
}

user { 'jet':
  ensure     => present,
  uid        => '10000',
  gid        => '10000',
  shell      => '/bin/bash',
  home       => '/home/jet',
  purge_ssh_keys => true,
}

# Ensure the home directory exists with the right permissions
file { "/home/jet":
  ensure            =>  directory,
  owner             =>  jet,
  group             =>  jet,
  mode              =>  '0750',
  require           =>  [ User["jet"], Group["jet"] ],
}

# Ensure the .ssh directory exists with the right permissions
file { "/home/jet/.ssh":
  ensure            =>  directory,
  owner             =>  jet,
  group             =>  jet,
  mode              =>  '0700',
  require           =>  File["/home/jet"],
}

ssh_authorized_key { 'jet@magpie.example.com':
  ensure => present,
  user   => 'jet',
  type   => 'ssh-rsa',
  key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC/PMJ7B/EiWn51N0jIGpUcVxg+GuWCMnudK+/sySNguhtQYXHOMGXVP3I7RkyjMD+y18K27YABAgrQMtexowlZKFI/dTdPAZCob7m2pr4RyW6UySp6bPNzldHhN0iyHqt2/gnfXLX2OCwGe8yGsCsWEIb19xaYWJkL/0rmKaq82/vqqMOmBko3JOom1UPExr9TXc8kQCBXVVL1U9WQyOJnZewPlrbzj8xIdtUX5Vv5lmU2VsLl+vvC7fNnLJeCocWjdfGf1j0eTJtAYgSc2FujrjNhfU0+YTRs9hextq4SQlgHPHA4KNIfZdxT9/mOIET1I5L0+dNf0VawZJD0Gpf/',
  require  =>  File["/home/jet/.ssh"],
}

$type = "user"

$resources = {
  'nick' => { uid    => '1330',
              groups => ['jet'], },
  'dan'  => { uid    => '1308',
              groups => ['jet'], },
}

$defaults = { gid => 'jet',
              managehome => true,
              shell      => '/bin/bash',
            }

$resources.each |String $resource, Hash $attributes| {
  Resource[$type] {
    $resource: * => $attributes;
    default:   * => $defaults;
  }
}