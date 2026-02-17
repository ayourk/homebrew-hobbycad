# =====================================================================
#  HobbyCAD-homebrew — Formula/opencascade@7.9.2.rb — OCCT 7.9.2 (pinned)
# =====================================================================
#
#  Latest stable release for HobbyCAD.
#  See docs/dev_environment_setup.txt §6.4.
#
# =====================================================================
class OpencascadeAT792 < Formula
  desc "3D modeling and numerical simulation software for CAD/CAM/CAE"
  homepage "https://dev.opencascade.org/"
  url "https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_9_2.tar.gz"
  version "7.9.2"
  sha256 "3cd080d3fc33ba0c6c157e110afe3e015859524c4694dbb09812ec9d61595639"
  license "LGPL-2.1-only"

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freetype"

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
           "-DBUILD_LIBRARY_TYPE=Shared",
           "-DBUILD_MODULE_Draw=OFF",
           "-DUSE_FREETYPE=ON",
           "-DUSE_TBB=OFF",
           "-DUSE_FREEIMAGE=OFF",
           "-DUSE_RAPIDJSON=OFF",
           "-DUSE_VTK=OFF",
           "-DINSTALL_SAMPLES=OFF",
           "-DINSTALL_TEST_CASES=OFF",
           "-DINSTALL_DOC_Overview=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      This is a version-pinned formula for HobbyCAD.

      It is keg-only, so you must tell CMake where to find it:

        -DOpenCASCADE_DIR=#{opt_lib}/cmake/opencascade

      Or export the environment variable:

        export OpenCASCADE_DIR=#{opt_lib}/cmake/opencascade
    EOS
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <Standard_Version.hxx>
      #include <cstdio>
      int main() {
        printf("OCCT %s\\n", OCC_VERSION_COMPLETE);
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++11", "test.cpp",
           "-I#{include}/opencascade",
           "-L#{lib}", "-lTKernel",
           "-o", "test"
    assert_match "7.9.2", shell_output("./test")
  end
end
