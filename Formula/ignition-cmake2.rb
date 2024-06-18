class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.17.2.tar.bz2"
  sha256 "3d84a80a83098f0ac5199c33be420e46d4b53cb06da2cd326d22f1c644014e68"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-cmake2-2.17.2_4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "384d6550eb8b0469fb9bb35e02b17768c81322f099a94145a96224aadaec5153"
    sha256 cellar: :any_skip_relocation, ventura:      "c21550a5912fc3f5db3c473b98a67ff967be2f2e3c0c7fe9f534da2b329163f6"
    sha256 cellar: :any_skip_relocation, monterey:     "086738a9ba867fff205e31f7b7a7ac1f8773eded39907385db9f53b7f73413dd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8af96287011e039247870ec60c937f31468a09d9e72f86f04cbaad41fd77b9a8"
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
