# =====================================================================
#  HobbyCAD-homebrew   Formula/opencascade@8.0.1.rb   OCCT 8.0.1 (pinned)
# =====================================================================
#
#  The OCCT release HobbyCAD builds against on every platform.  Same
#  tarball as the Launchpad PPA's opencascade 8.0.1+p1-1: stock upstream
#  V8_0_1 with the HobbyCAD BSD portability series baked in (+p1), made
#  reproducibly by HobbyCAD-libs/opencascade/make-occt-orig.sh.  The
#  series only touches BSD platform lists (Standard_CLocaleSentry,
#  OSD_Path, OSD_MemInfo, Standard_CString, occt_csf.cmake; OpenCASCADE
#  issue #1515), so on macOS it builds the same code as upstream; it is
#  used here so that all channels ship one identical source.
#  See docs/dev_environment_setup.txt section 22.1.
#
#  opencascade@7.9.2 stays in the tap as the previous pin.
#
# =====================================================================
class OpencascadeAT801 < Formula
  desc "3D modeling and numerical simulation software for CAD/CAM/CAE"
  homepage "https://dev.opencascade.org/"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/opencascade_8.0.1+p1.orig.tar.xz"
  version "8.0.1p1"
  sha256 "966a79fb0fbed4f947b6a3cc456eed61dd584f8a165869afa9f9d232f275172e"
  license "LGPL-2.1-only"

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freetype"

  def install
    # CMAKE_POLICY_VERSION_MINIMUM is still needed at 8.0.1: upstream's
    # cmake_minimum_required is below what CMake 4 accepts.
    # RapidJSON (glTF) and TBB stay off as in the 7.9.2 pin; HobbyCAD
    # links neither TKDEGLTF nor a TBB-enabled OCCT.
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
    system ENV.cxx, "-std=c++17", "test.cpp",
           "-I#{include}/opencascade",
           "-L#{lib}", "-lTKernel",
           "-o", "test"
    assert_match "8.0.1", shell_output("./test")
  end
end
