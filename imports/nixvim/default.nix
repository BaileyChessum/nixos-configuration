{ pkgs, lib, ... }:

let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
  ];

  # Some places to look at plagarising: 
  #   - https://github.com/Ahwxorg/nixvim-config/blob/master/config/plugins.nix


  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;

    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      list = true;

      shiftwidth = 2;        # Tab width should be 2
      tabstop = 2;

      expandtab = true;
      autoindent = true;
    };

    plugins = {
      lint = {
        enable = true;
        lintersByFt = {
          text = ["vale"];
          json = ["jsonlint"];
          markdown = ["vale"];
          rst = ["vale"];
          ruby = ["ruby"];
          janet = ["janet"];
          inko = ["inko"];
          clojure = ["clj-kondo"];
          dockerfile = ["hadolint"];
          terraform = ["tflint"];
        };
      };

      # Nix expressions in Neovim
      nix = {
        enable = true;
      };

      # Language server
      lsp = {
        enable = true;
        servers = {
          # Average webdev LSPs
          # ts-ls.enable = true; # TS/JS
          ts_ls.enable = true; # TS/JS
          cssls.enable = true; # CSS
          tailwindcss.enable = true; # TailwindCSS
          html.enable = true; # HTML
          astro.enable = true; # AstroJS
          phpactor.enable = true; # PHP
          svelte.enable = false; # Svelte
          vuels.enable = false; # Vue
          pyright.enable = true; # Python
          marksman.enable = true; # Markdown
          nil_ls.enable = true; # Nix
          dockerls.enable = true; # Docker
          bashls.enable = true; # Bash
          clangd.enable = true; # C/C++
          csharp_ls.enable = true; # C#
          yamlls.enable = true; # YAML
          ltex = {
            enable = true;
            settings = {
              enabled = [ "astro" "html" "latex" "markdown" "text" "tex" "gitcommit" ];
              completionEnabled = true;
              language = "en-US";
            };
          };
          gopls = { # Golang
            enable = true;
            autostart = true;
          };

          lua_ls = { # Lua
            enable = true;
            settings.telemetry.enable = false;
          };

          # Rust
          rust_analyzer = {
            enable = true;
            installRustc = true;
            installCargo = true;
          };
        };
      };
    };

    # extraPlugins = [
    #   pkgs.vimPlugins.moonfly
    # ];
    # colorscheme = "moonfly";
  };
}
