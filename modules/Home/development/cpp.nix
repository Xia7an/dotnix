{ pkgs, ... }: {
  home.packages = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    pkg-config
    autogen
    binutils
    time
    llvm_19
    lldb
  ];
}
