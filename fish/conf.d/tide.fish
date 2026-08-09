# Tide prompt configuration - the source of truth for this prompt.
#
# Exported from the universal variables that "tide configure" had written
# (~/.config/fish/fish_variables) on 2026-08-09, so the prompt is reproducible
# from a file instead of an untracked variable store.
#
# NOTE: these are global; fish resolves global before universal. If you run
# "tide configure" again it writes universal vars that these will shadow, and
# the new choices will appear to do nothing. Re-export this file afterwards.

set -g tide_aws_bg_color yellow
set -g tide_aws_color brblack
set -g tide_aws_icon 
set -g tide_character_color brgreen
set -g tide_character_color_failure brred
set -g tide_character_icon ❯
set -g tide_character_vi_icon_default ❮
set -g tide_character_vi_icon_replace ▶
set -g tide_character_vi_icon_visual V
set -g tide_cmd_duration_bg_color yellow
set -g tide_cmd_duration_color black
set -g tide_cmd_duration_decimals 0
set -g tide_cmd_duration_icon 
set -g tide_cmd_duration_threshold 3000
set -g tide_context_always_display false
set -g tide_context_bg_color brblack
set -g tide_context_color_default yellow
set -g tide_context_color_root yellow
set -g tide_context_color_ssh yellow
set -g tide_context_hostname_parts 1
set -g tide_crystal_bg_color brwhite
set -g tide_crystal_color black
set -g tide_crystal_icon 
set -g tide_direnv_bg_color bryellow
set -g tide_direnv_bg_color_denied brred
set -g tide_direnv_color black
set -g tide_direnv_color_denied black
set -g tide_direnv_icon ▼
set -g tide_distrobox_bg_color brmagenta
set -g tide_distrobox_color black
set -g tide_distrobox_icon 󰆧
set -g tide_docker_bg_color blue
set -g tide_docker_color black
set -g tide_docker_default_contexts default colima
set -g tide_docker_icon 
set -g tide_elixir_bg_color magenta
set -g tide_elixir_color black
set -g tide_elixir_icon 
set -g tide_gcloud_bg_color blue
set -g tide_gcloud_color black
set -g tide_gcloud_icon 󰊭
set -g tide_git_bg_color green
set -g tide_git_bg_color_unstable yellow
set -g tide_git_bg_color_urgent red
set -g tide_git_color_branch black
set -g tide_git_color_conflicted black
set -g tide_git_color_dirty black
set -g tide_git_color_operation black
set -g tide_git_color_staged black
set -g tide_git_color_stash black
set -g tide_git_color_untracked black
set -g tide_git_color_upstream black
set -g tide_git_icon 
set -g tide_git_truncation_length 24
set -g tide_git_truncation_strategy 
set -g tide_go_bg_color brcyan
set -g tide_go_color black
set -g tide_go_icon 
set -g tide_java_bg_color yellow
set -g tide_java_color black
set -g tide_java_icon 
set -g tide_jobs_bg_color brblack
set -g tide_jobs_color green
set -g tide_jobs_icon 
set -g tide_jobs_number_threshold 1000
set -g tide_kubectl_bg_color blue
set -g tide_kubectl_color black
set -g tide_kubectl_icon 󱃾
set -g tide_left_prompt_frame_enabled true
set -g tide_left_prompt_items os pwd git newline character
set -g tide_left_prompt_prefix 
set -g tide_left_prompt_separator_diff_color 
set -g tide_left_prompt_separator_same_color 
set -g tide_left_prompt_suffix 
set -g tide_nix_shell_bg_color brblue
set -g tide_nix_shell_color black
set -g tide_nix_shell_icon 
set -g tide_node_bg_color green
set -g tide_node_color black
set -g tide_node_icon 
set -g tide_os_bg_color white
set -g tide_os_color black
set -g tide_os_icon 
set -g tide_php_bg_color blue
set -g tide_php_color black
set -g tide_php_icon 
set -g tide_private_mode_bg_color brwhite
set -g tide_private_mode_color black
set -g tide_private_mode_icon 󰗹
set -g tide_prompt_add_newline_before true
set -g tide_prompt_color_frame_and_connection brblack
set -g tide_prompt_color_separator_same_color brblack
set -g tide_prompt_icon_connection ' '  # was ─ : no line drawn between the left and right prompt
set -g tide_prompt_min_cols 34
set -g tide_prompt_pad_items true
set -g tide_prompt_transient_enabled true
set -g tide_pulumi_bg_color yellow
set -g tide_pulumi_color black
set -g tide_pulumi_icon 
set -g tide_pwd_bg_color 444444  # neutral grey, from devaslife (was: blue)
set -g tide_pwd_color_anchors brwhite
set -g tide_pwd_color_dirs brwhite
set -g tide_pwd_color_truncated_dirs white
set -g tide_pwd_icon 
set -g tide_pwd_icon_home 
set -g tide_pwd_icon_unwritable 
set -g tide_pwd_markers .bzr .citc .git .hg .node-version .python-version .ruby-version .shorten_folder_marker .svn .terraform Cargo.toml composer.json CVS go.mod package.json build.zig
set -g tide_python_bg_color brblack
set -g tide_python_color cyan
set -g tide_python_icon 󰌠
set -g tide_right_prompt_frame_enabled true
set -g tide_right_prompt_items status cmd_duration context jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig time
set -g tide_right_prompt_prefix 
set -g tide_right_prompt_separator_diff_color 
set -g tide_right_prompt_separator_same_color 
set -g tide_right_prompt_suffix 
set -g tide_ruby_bg_color red
set -g tide_ruby_color black
set -g tide_ruby_icon 
set -g tide_rustc_bg_color red
set -g tide_rustc_color black
set -g tide_rustc_icon 
set -g tide_shlvl_bg_color yellow
set -g tide_shlvl_color black
set -g tide_shlvl_icon 
set -g tide_shlvl_threshold 1
set -g tide_status_bg_color black
set -g tide_status_bg_color_failure red
set -g tide_status_color green
set -g tide_status_color_failure bryellow
set -g tide_status_icon ✔
set -g tide_status_icon_failure ✘
set -g tide_terraform_bg_color magenta
set -g tide_terraform_color black
set -g tide_terraform_icon 󱁢
set -g tide_time_bg_color white
set -g tide_time_color black
set -g tide_time_format '%T'
set -g tide_toolbox_bg_color magenta
set -g tide_toolbox_color black
set -g tide_toolbox_icon 
set -g tide_vi_mode_bg_color_default white
set -g tide_vi_mode_bg_color_insert cyan
set -g tide_vi_mode_bg_color_replace green
set -g tide_vi_mode_bg_color_visual yellow
set -g tide_vi_mode_color_default black
set -g tide_vi_mode_color_insert black
set -g tide_vi_mode_color_replace black
set -g tide_vi_mode_color_visual black
set -g tide_vi_mode_icon_default D
set -g tide_vi_mode_icon_insert I
set -g tide_vi_mode_icon_replace R
set -g tide_vi_mode_icon_visual V
set -g tide_zig_bg_color yellow
set -g tide_zig_color black
set -g tide_zig_icon 
