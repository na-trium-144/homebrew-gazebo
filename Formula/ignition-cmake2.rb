class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.17.1.tar.bz2"
  sha256 "3b678f90d2db79912cfbe4c93f3eed695b8a391847fe9e6454f1c6366370650c"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-cmake2-2.17.1_1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "7c5df39304d54df3e547f610644b83adae8091e5ab4c0db1641c0a1b014a5f6f"
    sha256 cellar: :any_skip_relocation, ventura:      "26c80f1a5211437271f513e41a3dcfe17c459a8004e88d10e52156f3aa15bd7d"
    sha256 cellar: :any_skip_relocation, monterey:     "6444bf895a942991e1c5ceb66fc91c266c18f6062b7a7fe0438bef7c85fcdecb"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      project(ignition-test VERSION 0.1.0)
      find_package(ignition-cmake2 REQUIRED)
      ign_configure_project()
      ign_configure_build(QUIT_IF_BUILD_ERRORS)
    EOS
    %w[doc include src test].each do |dir|
      mkdir dir do
        touch "CMakeLists.txt"
      end
    end
    mkdir "build" do
      system "cmake", ".."
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
