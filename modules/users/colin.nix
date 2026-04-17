{ self, lib, ... }:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "colin" false false)
    {
      nixos.colin.users.users.colin.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvdpq/N0s0ldIe9Bp9oklODXf3dzwTL4XL1gZg1AJujSnhz1yJHhKv6pMmRvf9H+znzxWAB6BWAULMp5aWob3wVbgSRrxwXXEGVKinnBWZ6Ob7Ax/qFgk7jRMRwdnXWpLMQFmo63CVJJEpuVrVVxoJgMqFLJ22fhOckzuet+W/h2zh5eGntKuxE1P5rd4DnkAmz2xrXPcSHpRYuBQLuUer5PMtucTue6bUazomQXtUv269pBprYz+awnLsI9TOaX3Vpr3OWUN84fIylzWukYiaU0NlfMni9MP+WJgaenaCPa/f0c+hLNuETp23/I5lOVyPOKLD829pfmB3OvcWYcP6HxNRs+Dc126IpqNYek2bmJvuRiYINmPdZOmbGSNzQ43StGPw/vo/XeII/8GMWQgFFOT0HSpXr2xlr0HVxDzRS4mxRZrEHk3qOCuIq4Hpbr7/FM+CG5Akpgyk9svKki3YlzjmjWwJjbzXsMURnYTut454ord5MVTLZBoaG1Oxobk= colin@Colins-MacBook-Pro.local"
      ];
    }
  ];
}
