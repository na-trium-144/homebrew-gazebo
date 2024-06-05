class IgnitionTools < Formula
  desc "Entry point for ignition command-line tools"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-tools/releases/ignition-tools-1.5.0.tar.bz2"
  sha256 "00cf5d2eb6222784d6db4de6baffc068013b1fd71d733f496c9f99addc12117d"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-tools.git", branch: "ign-tools1"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-tools-1.5.0_3"
    sha256 cellar: :any, arm64_sonoma: "373d5769c688e65c277681813b88fd6cf8815362d65cbc2a99bbf7aac095a170"
    sha256 cellar: :any, ventura:      "77fccceedbf1d1cfedd14b2f53ce082891fde92b84ef36bb1d715ce89c5646c6"
    sha256 cellar: :any, monterey:     "f983d07dcf911bbb4b42b0441f1af52b4179fd1f9e19444ba18100befe7ed337"
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
