{ ... }: {
  # 平文ファイルとして切り出せる辞書とキーマップは repo で管理する。
  # Linux 側でも SKK 系 IME に流用しやすいよう `config/skk` に集約する。
  home.file."Library/Application Support/AquaSKK/keymap.conf".source =
    ../../../config/skk/keymap.conf;
  home.file."Library/Application Support/AquaSKK/skk-jisyo.utf8".source =
    ../../../config/skk/skk-jisyo.utf8;
  home.file."Library/Application Support/AquaSKK/BlacklistApps.plist".source =
    ../../../config/darwin/aquaskk/BlacklistApps.plist;

  targets.darwin.defaults."jp.sourceforge.inputmethod.aquaskk" = {
    beep_on_registration = false;
    candidate_window_font_name = "Trebuchet MS";
    candidate_window_font_size = 18;
    candidate_window_labels = "ASDFJKL";
    delete_okuri_when_quit = true;
    display_shortest_match_of_kana_conversions = false;
    dynamic_completion_range = 1;
    enable_annotation = false;
    enable_dynamic_completion = false;
    enable_extended_completion = true;
    enable_private_mode = false;
    enable_skkdap = false;
    enable_skkserv = false;
    fix_intermediate_conversion = true;
    handle_recursive_entry_as_okuri = false;
    inline_backspace_implies_commit = false;
    keyboard_layout = "com.apple.keylayout.US";
    max_count_of_inline_candidates = 4;
    minimum_completion_length = 0;
    openlab_host = "openlab.ring.gr.jp";
    openlab_path = "/skk/skk/dic";
    put_candidate_window_upward = false;
    show_input_mode_icon = true;
    skkdap_folder = "~/Library/Application Support/AquaSKK";
    skkdap_port = 2178;
    skkserv_localonly = true;
    skkserv_port = 1178;
    sub_keymaps = [ ];
    sub_rules = [ ];
    suppress_newline_on_commit = true;
    use_individual_input_mode = false;
    use_numeric_conversion = true;
    user_dictionary_path = "~/Library/Application Support/AquaSKK/skk-jisyo.utf8";
  };
}
