{ ... }: {
  security.sudo = {
    enable = true;
    extraRules = [{
      users    = [ "inoyu" ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];
  };
}
