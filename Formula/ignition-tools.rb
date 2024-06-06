class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.5.0.tar.bz2"
  sha256 "00cf5d2eb6222784d6db4de6baffc068013b1fd71d733f496c9f99addc12117d"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-tools-1.5.0_4"
    sha256 cellar: :any,                 arm64_sonoma: "fe66b764da01b142881f91656cb4b134b7d32381bbcf33d0383824ec72cbe8e4"
    sha256 cellar: :any,                 ventura:      "5cffebfc69db0c0cb3629fa69578fda06a764b917674bb3ab7861d07ae0836e6"
    sha256 cellar: :any,                 monterey:     "565aed535e8747103bf4c46fb21ba50ca73c997971c8abb0385422ca6bb2b967"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e491fab8ac7050bb5232cacd9e41bc3a505831213d7e2549e8930ea42ae10ef7"
  end

  depends_on "cmake" => :build
  depends_on "libyaml" => :test
  depends_on "ruby" => :test

  def install
    inreplace "src/ign.in" do |s|
      s.gsub! "@CMAKE_INSTALL_PREFIX@", HOMEBREW_PREFIX
    end

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    mkdir testpath/"config"
    (testpath/"config/test.yaml").write <<~EOS
      --- # Test subcommand
      format: 1.0.0
      library_name: test
      library_path: path
      library_version: 2.0.0
      commands:
          - test  : Test utility
      ---
    EOS
    ENV["IGN_CONFIG_PATH"] = testpath/"config/"
    system "#{bin}/ign", "test", "--versions"
  end
end
