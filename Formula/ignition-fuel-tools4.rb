class IgnitionFuelTools4 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools4-4.9.1.tar.bz2"
  sha256 "35b8cdceae46f50360081eb1b310366ae085a8c64d88fee7175f2b0582e454a2"
  license "Apache-2.0"
  revision 13

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "ign-fuel-tools4"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/ignition-fuel-tools4-4.9.1_13"
    sha256 cellar: :any, arm64_sonoma: "990d805cb88c07f2834a4c1f321e5a1a65d8c415a8bcd951b777f1619904644d"
    sha256 cellar: :any, ventura:      "df5a866d1df3565e3f2d90ec6e8668784004856be937571e0837cfbc06129aad"
    sha256 cellar: :any, monterey:     "c2c5522057fe3e803081d72cb00204c26ee545c66be0230b3d9fafc622191985"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs5"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

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
      #include <ignition/fuel_tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel_tools4 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools4::ignition-fuel_tools4)
    EOS
    # # test building with pkg-config
    # system "pkg-config", "--cflags", "ignition-fuel_tools4"
    # cflags = `pkg-config --cflags ignition-fuel_tools4`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                "-lignition-fuel_tools4",
    #                "-lc++",
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
