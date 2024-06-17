class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.17.2.tar.bz2"
  sha256 "3d84a80a83098f0ac5199c33be420e46d4b53cb06da2cd326d22f1c644014e68"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-cmake2-2.17.2_3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "52f284e77c378013b846faa769b6b8926d9dd4fc2c4c2deab630150472550bf1"
    sha256 cellar: :any_skip_relocation, ventura:      "25cb06d49489602d7e97c993de4ac82efa789adea61c0d5542b01d4d9d135157"
    sha256 cellar: :any_skip_relocation, monterey:     "2d17fc0740cffc1a87a04fc0ff2f2f81b0df40112cb80119c91b38e2fcae45bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "122d71567f3ffa69e9f1eae8465dafbd36efdc52fdda52209825a182fa639225"
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
