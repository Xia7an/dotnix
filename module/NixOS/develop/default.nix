{ pkgs, inputs, ...} : {
  imports = [
    ./mise.nix
    ./python.nix
    ./vscode.nix
  ];
}
