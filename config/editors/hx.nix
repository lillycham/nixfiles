{pkgs, ...}:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "ayu_mirage";
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
      };
      keys.insert = {
        "C-j" = ["normal_mode" "copy_selection_on_next_line" "insert_mode"];
        "C-k" = ["normal_mode" "copy_selection_on_prev_line" "insert_mode"];
      };
      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        bufferline = "always";
        statusline = {
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };
    };
  };
}