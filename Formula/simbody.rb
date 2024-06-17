class Simbody < Formula
  desc "Multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/refs/tags/Simbody-3.7.tar.gz"
  sha256 "d371a92d440991400cb8e8e2473277a75307abb916e5aabc14194bea841b804a"
  license "Apache-2.0"
  revision 4

  head "https://github.com/simbody/simbody.git", branch: "master"

  bottle do
    root_url "https://github.com/na-trium-144/homebrew-gazebo/releases/download/simbody-3.7_3"
    sha256 arm64_sonoma: "973bbae82679e53bf5edf104797f9e62a1288c904a1e4b4eb4620bc8cbe98dde"
    sha256 ventura:      "855261023ef138fff125dfcd8dd67d5308f5c71451b8711d2410ae45b270b583"
    sha256 monterey:     "692655ae02651fb5e072bef9d8b09292fd94d007d5617d08e675d68c6b6ffeb2"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkg-config" => [:build, :test]

  def install
    # Don't use 10.11 SDK frameworks on 10.10 with xcode7
    ENV.delete("MACOSX_DEPLOYMENT_TARGET")
    ENV.delete("SDKROOT")

    # use build folder
    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DCMAKE_INSTALL_RPATH=#{rpath}"
      system "make", "doxygen"
      system "make", "install"
    end

    inreplace Dir[lib/"cmake/simbody/SimbodyTargets-*.cmake"],
        %r{/Applications/+Xcode.app/[^;]*/System/Library},
        "/System/Library", false
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "simbody/Simbody.h"
      using namespace SimTK;
      int main() {
        // Create the system.
        MultibodySystem system;
        SimbodyMatterSubsystem matter(system);
        GeneralForceSubsystem forces(system);
        Force::UniformGravity gravity(forces, matter, Vec3(0, -9.8, 0));
        Body::Rigid pendulumBody(MassProperties(1.0, Vec3(0), Inertia(1)));
        pendulumBody.addDecoration(Transform(), DecorativeSphere(0.1));
        MobilizedBody::Pin pendulum1(matter.Ground(), Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        MobilizedBody::Pin pendulum2(pendulum1, Transform(Vec3(0)),
                                     pendulumBody, Transform(Vec3(0, 1, 0)));
        // Initialize the system and state.
        system.realizeTopology();
        State state = system.getDefaultState();
        pendulum2.setRate(state, 5.0);
        // Simulate it.
        RungeKuttaMersonIntegrator integ(system);
        TimeStepper ts(system, integ);
        ts.initialize(state);
        ts.stepTo(50.0);
      }
    EOS
    system "pkg-config", "simbody"
    flags = `pkg-config --cflags --libs simbody`.split
    system ENV.cxx, "test.cpp", *flags, "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    # ! requires system with single argument, which uses standard shell
    # put in variable to avoid audit complaint
    # enclose / in [] so the following line won't match itself
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
