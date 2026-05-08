{ pkgs, ... }: {
  home.packages = with pkgs; [
    llvm_19
    lldb
  ];
}