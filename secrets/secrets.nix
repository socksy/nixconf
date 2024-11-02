let
users = {
  ben = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiZYmr4v7/cMgZB4qWB8oKMA3ZTDMuViHrr1VPItwIj ben@lovell.io";
};
in
{
  "searx_password.age".publicKeys = [ users.ben ];
}
