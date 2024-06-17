class Tinyxml1 < Formula
  desc "XML parser"
  homepage "https://sourceforge.net/projects/tinyxml/"
  url "https://downloads.sourceforge.net/project/tinyxml/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz"
  sha256 "15bdfdcec58a7da30adc87ac2b078e4417dbe5392f3afb719f9ba6d062645593"
  license "Zlib"
  revision 4

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/tinyxml1-2.6.2_3"
    sha256 cellar: :any,                 arm64_sonoma: "12c24174eb74ef85da941bed7857271eda285c4d536ef39a65a35bf9cbaa1255"
    sha256 cellar: :any,                 ventura:      "f5b3eb4ee6c20e9d4a8240e8f6a18e0030143c93664f5763dff85885168aa848"
    sha256 cellar: :any,                 monterey:     "d6655a8da18000b223c1fd036c45e2bdd43180a2a21b503fa8c1390fba1467e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d998a2ea55ca1103aefeea980fe10d4d8215218c385d81e6c66397a24f7bdcfc"
  end

  depends_on "cmake" => :build

  conflicts_with "tinyxml", because: "differing version of the same formula"

  # The first two patches are taken from the debian packaging of tinyxml.
  #   The first patch enforces use of stl strings, rather than a custom string type.
  #   The second patch is a fix for incorrect encoding of elements with special characters
  #   originally posted at https://sourceforge.net/p/tinyxml/patches/51/
  # The third patch adds a CMakeLists.txt file to build a shared library and provide an install target
  #   submitted upstream as https://sourceforge.net/p/tinyxml/patches/66/
  patch do
    url "https://raw.githubusercontent.com/robotology/yarp/59eedfbaa1069aa5f03a4a9980d984d59decd55c/extern/tinyxml/patches/enforce-use-stl.patch"
    sha256 "16a5b5e842eb0336be606131e5fb12a9165970f7bd943780ba09df2e1e8b29b1"
  end

  patch do
    url "https://raw.githubusercontent.com/robotology/yarp/59eedfbaa1069aa5f03a4a9980d984d59decd55c/extern/tinyxml/patches/entity-encoding.patch"
    sha256 "c5128e03933cd2e22eb85554d58f615f4dbc9177bd144cae2913c0bd7b140c2b"
  end

  patch do
    url "https://gist.githubusercontent.com/scpeters/6325123/raw/cfb079be67997cb19a1aee60449714a1dedefed5/tinyxml_CMakeLists.patch"
    sha256 "32160135c27dc9fb7f7b8fb6cf0bf875a727861db9a07cf44535d39770b1e3c7"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    (lib+"pkgconfig/tinyxml.pc").write pc_file
  end

  def pc_file
    <<~EOS
      prefix=#{opt_prefix}
      exec_prefix=${prefix}
      libdir=${exec_prefix}/lib
      includedir=${prefix}/include

      Name: TinyXml
      Description: Simple, small, C++ XML parser
      Version: #{version}
      Libs: -L${libdir} -ltinyxml
      Cflags: -I${includedir}
    EOS
  end

  test do
    (testpath/"test.xml").write <<~EOS
      <?xml version="1.0" ?>
      <Hello>World</Hello>
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include <tinyxml.h>

      int main()
      {
        TiXmlDocument doc ("test.xml");
        doc.LoadFile();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-ltinyxml", "-o", "test"
    system "./test"
  end
end
