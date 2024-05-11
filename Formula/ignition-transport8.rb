class IgnitionTransport8 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport8-8.5.0.tar.bz2"
  sha256 "5edd15699e35ade5ad2f814af1f5e96a866f7908e16b55333abb23978f44d4c6"
  license "Apache-2.0"
  revision 11

  head "https://github.com/gazebosim/gz-transport.git", branch: "ign-transport8"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-transport8-8.5.0_11"
    sha256 arm64_sonoma: "b34eb1df154a006a967eab97065688d8400d9b266926415da54d47a28235b0c0"
    sha256 ventura:      "4513f88f57077a1df9a813e88a84d54ac335d1978bf6248b60ab690b555637a8"
    sha256 monterey:     "285751decc94049bc965ccb8de6f7f77797dae9690b49a5950726c61bb51ba73"
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs5"
  depends_on "ignition-tools"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"
  depends_on "zeromq"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::NodeOptions options;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-transport8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport8::ignition-transport8)
    EOS
    system "pkg-config", "ignition-transport8"
    # cflags = `pkg-config --cflags ignition-transport8`.split
    # ldflags = `pkg-config --libs ignition-transport8`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    # ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
    # system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
