{ ... }:

{
  # nix develop が bash を使うため、bash でも starship init が効くようにする
  programs.bash = {
    enable = true;
    initExtra = ''
      shopt -s autocd
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };
}
