class Lotus < Formula
  desc "lotus filecoin daemon and client"
  homepage "filecoin.io"
  url "https://github.com/filecoin-project/lotus/archive/refs/tags/v1.10.0.tar.gz"
  sha256 "930f78b32856c03c1e572a2a3cc822c8c1b97c3baf53728e140be49070e67118"
  license "Apache-2.0/MIT"
  head "https://github.com/filecoin-project/lotus"

  depends_on "pkg-config" => :build
  depends_on "go"         => :build
  depends_on "jq"         => :build
  depends_on "rustup"     => :build
  depends_on "hwloc"

  def install
    ENV["CARGO_HOME"] = File.join(prefix ,"_CARGO")
    ENV["RUSTUP_HOME"] = File.join(prefix, "_RUSTUP")
    ENV["CGO_ENABLED"] = "1"
    ENV["FFI_BUILD_FROM_SOURCE"] = "1"

    # update submodules
    system "git clone https://github.com/filecoin-project/filecoin-ffi.git extern/filecoin-ffi"
    system "git clone https://github.com/filecoin-project/serialization-vectors.git extern/serialization-vectors"
    system "git clone https://github.com/filecoin-project/test-vectors.git extern/test-vectors"
    system "touch build/.update-modules"

    # rustup
    system "mkdir " + ENV["RUSTUP_HOME"] + " " + ENV["CARGO_HOME"]
    system "rustup-init --no-modify-path -y"
    ENV.prepend_path("PATH", ENV["CARGO_HOME"] + "/bin")

    # make
    system "go mod tidy"
    system "go mod download"
    system "make all"
    bin.install "lotus"
    bin.install "lotus-miner"
    bin.install "lotus-worker"

    # cleanup
    system "rm -rf " + ENV["RUSTUP_HOME"] + " " + ENV["CARGO_HOME"]
  end
end
