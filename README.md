# pytorch-darwin-env
PyTorch development environment with Metal acceleration for Darwin

## Description
This project provides a Nix-based development environment for PyTorch with Metal acceleration support on macOS (Darwin) systems with Apple Silicon. It includes a flake configuration for easy setup and a verification script to check PyTorch installation and benchmark Metal acceleration performance.

This repository exists as a workaround for the following issue in the Nixpkgs repository:

[Package request: pytorch on darwin with GPU (MPS) support #243868](https://github.com/NixOS/nixpkgs/issues/243868)

The current PyTorch package in Nixpkgs for aarch64-darwin does not support GPU acceleration via Metal Performance Shaders (MPS). This project provides a solution by using the PyTorch-provided wheel that includes MPS support, allowing users to leverage GPU acceleration on Apple Silicon Macs.

## Features
- Nix-based development environment
- PyTorch 2.0.1 with Metal acceleration support
- Performance benchmark script comparing CPU and MPS (Metal Performance Shaders) execution

## Requirements
- macOS on Apple Silicon (M1/M2) machine
- Nix package manager with flakes support

## Usage
### Using the flake directly (without cloning)
You can use this environment directly without cloning the repository:

```bash
nix develop "github:david-r-cox/pytorch-darwin-env"
```

Or to run the verification script directly:

```bash
nix run "github:david-r-cox/pytorch-darwin-env#verificationScript"
```

### Local setup
1. Clone this repository:
```bash
git clone https://github.com/david-r-cox/pytorch-darwin-env.git
cd pytorch-darwin-env
```
2. Enter the Nix development environment:
```bash
nix develop
```
3. Run the verification and benchmark script:
```bash
verify-pytorch-metal
```

This script will:
- Check the PyTorch version
- Verify MPS (Metal Performance Shaders) availability
- Run a matrix multiplication benchmark on both CPU and MPS
- Display the performance comparison between CPU and MPS

```bash
$ verify-pytorch-metal # M1 Max
PyTorch version: 2.0.1
MPS available: True
CPU time: 1.3895 seconds
MPS time: 0.0061 seconds
MPS speedup: 228.17x
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
