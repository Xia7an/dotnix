{ pkgs, ... }: {
  home.packages = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    pkg-config
    autogen
    time
    llvm_19
    lldb
  ];
}
