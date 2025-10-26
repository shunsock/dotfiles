{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    claude-code
  ];

  environment.home.".claude/settings.json".text = ''
  {
    "permissions": {
      "allow": [
        "Bash(man:*)",
        "Bash(task:*)",
        "Bash(task gh read shunsock/dotfiles/azuma)",
        "Read(~/hobby/dotfiles/azuma)",
        "Read(./README.md)",
        "Read(./docs/**)"
      ],

      "ask": [
        "Bash(task gh:*)",
        "Write(./*)"
      ],

      "deny": [
        "Bash(rm -rf /)",
        "Bash(rm -rf /:*)",
        "Bash(rm -rf ~)",
        "Bash(rm -rf ~/:*)",

        "Read(./.env)",
        "Read(./.env.*)",
        "Read(./secrets/**)",
        "Read(./config/credentials.json)"
      ]
    },

    "defaultMode": "askEdits",
  }
  ''
}
