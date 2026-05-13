{ pkgs, ... }: {
  home.packages = with pkgs; [
    postgresql_17
    supabase-cli
  ];
}