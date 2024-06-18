class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.5.0.tar.bz2"
  sha256 "00cf5d2eb6222784d6db4de6baffc068013b1fd71d733f496c9f99addc12117d"
  license "Apache-2.0"
  revision 5

  head "https://github.com/gazebosim/gz-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-tools-1.5.0_5"
    sha256 cellar: :any,                 arm64_sonoma: "997f45936beaaab6583038dd730d5169c35ecd9e6911579724df53bff98f235b"
    sha256 cellar: :any,                 ventura:      "d8de7a8bb41a4e6c1513c484891777754463d86c88ebbeb92465c882ae6fe09c"
    sha256 cellar: :any,                 monterey:     "927c4ac1658231a9d6c7b769907dc040aa40e4b7233ef1e692600dbe895aee01"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "057de0878e816279b8b8b88f3f6f12a8f2210c5d016de233bad23d1decbe8fa5"
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
