class IgnitionMsgs5 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs5-5.11.0.tar.bz2"
  sha256 "59a03770c27b4cdb6d0b0f3de9f10f1c748a47b45376a297e1f30900edb893fd"
  license "Apache-2.0"
  revision 27

  head "https://github.com/gazebosim/gz-msgs.git", branch: "ign-msgs5"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-msgs5-5.11.0_27"
    sha256 cellar: :any, arm64_sonoma: "666df7e7fba0e05b2476bc53920f644a6ab5071b771c2524fbe771c50a59815e"
    sha256 cellar: :any, ventura:      "87c9800d95d9c8a5f63fdc8a5232898073377398eb29e2de803422bb3bdc112b"
    sha256 cellar: :any, monterey:     "d181eb763d93f5666706b6c4d70a05e5a7c91b4351de8fb0f94a5899d565382d"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gz-msgs/commit/0c0926c37042ac8f5aeb49ac36101acd3e084c6b.patch?full_index=1"
    sha256 "02dd3ee467dcdd1b5b1c7c26d56ebea34276fea7ff3611fb53bf27b99e7ba4bc"
  end

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
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-msgs5 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs5::ignition-msgs5)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs5"
    # cflags = `pkg-config --cflags ignition-msgs5`.split
    # ldflags = `pkg-config --libs ignition-msgs5`.split
    # compilation is broken with pkg-config, disable for now
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    # system "./test"
    # test building with cmake
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
