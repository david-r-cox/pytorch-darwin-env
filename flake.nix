{
  description = "PyTorch development environment with Metal acceleration for Darwin";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; })
          mkPoetryEnv
          defaultPoetryOverrides;

        pythonEnv = pkgs.python311;

        pytorchEnv = mkPoetryEnv {
          projectDir = self;
          python = pythonEnv;
          overrides = defaultPoetryOverrides.extend (self: super: {
            torch = super.torch.overridePythonAttrs (old: {
              src = pkgs.fetchurl {
                url = "https://files.pythonhosted.org/packages/85/68/f901437d3e3ef6fe97adb1f372479626d994185b8fa06803f5bdf3bb90fd/torch-2.0.1-cp311-none-macosx_11_0_arm64.whl";
                sha256 = "09z588l3prfkbkc3s650wdvqxpxgqwz50k507pqk5pywh3547ai5"; # From: nix-prefetch-url [url]
              };
              format = "wheel";
              propagatedBuildInputs = with pkgs.python311Packages; [
                astunparse
                filelock
                jinja2
                networkx
                numpy
                sympy
                typing-extensions
              ];
            });
          });
        };

        verificationScript = pkgs.writeScriptBin "verify-pytorch-metal" ''
          #!${pkgs.runtimeShell}
          export PYTHONPATH="${pytorchEnv}/lib/python3.11/site-packages:$PYTHONPATH"
          ${pythonEnv}/bin/python << EOF
          import torch
          import time

          print(f"PyTorch version: {torch.__version__}")
          print(f"MPS available: {torch.backends.mps.is_available()}")

          def run_benchmark(device):
              # Create large tensors
              a = torch.randn(5000, 5000, device=device)
              b = torch.randn(5000, 5000, device=device)

              start_time = time.time()

              # Perform matrix multiplication
              for _ in range(10):
                  c = torch.matmul(a, b)

              end_time = time.time()
              return end_time - start_time

          # CPU benchmark
          cpu_time = run_benchmark("cpu")
          print(f"CPU time: {cpu_time:.4f} seconds")

          if torch.backends.mps.is_available():
              # MPS benchmark
              mps_device = torch.device("mps")
              mps_time = run_benchmark(mps_device)
              print(f"MPS time: {mps_time:.4f} seconds")

              speedup = cpu_time / mps_time
              print(f"MPS speedup: {speedup:.2f}x")
          else:
              print("MPS device not found. Cannot run MPS benchmark.")
          EOF
        '';

      in
      rec {
        packages = {
          inherit pytorchEnv;
          inherit verificationScript;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pytorchEnv
            verificationScript
          ];
          shellHook = ''
            echo "PyTorch with Metal Acceleration Development Environment"
            echo "Run 'verify-pytorch-metal' to check PyTorch and MPS availability and performance"
          '';
        };
      }
    );
}
