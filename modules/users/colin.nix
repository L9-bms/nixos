{ self, ... }:
{
  flake.modules = (self.factory.user "colin" false false);
}
