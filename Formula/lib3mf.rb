class Lib3mf < Formula
  desc "3D Manufacturing Format library"
  homepage "https://3mf.io/"
  # The PPA's tarball: upstream 2.5.0's source-with-submodules archive
  # minus the prebuilt code-generator binaries, with the HobbyCAD +p1
  # series baked in (HobbyCAD-libs/lib3mf/make-lib3mf-orig.sh). One file
  # for the PPA, vcpkg and this formula, and no patches in any of them.
  # 2.5.0p1 = upstream 2.5.0 + four build-system fixes: the CMake config
  # takes the install layout from configure_package_config_file (it used
  # to name a directory three levels above itself), GNUInstallDirs after
  # project() without the CACHE PATH redeclarations that made CMake 4 turn
  # a relative "lib" into an absolute path under the working directory
  # (upstream issue #450), a pkg-config file that links lib3mf alone, and
  # a target that exports the C++11 its binding header needs (Apple clang
  # still defaults to C++98, so a consumer setting no standard failed).
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/lib3mf_2.5.0+p1.orig.tar.xz"
  version "2.5.0p1"
  sha256 "499750d0ba5bd13b39bb267ac9f49060f5afc63da90f750d52707387d4eed6a6"
  license "BSD-2-Clause"

  depends_on "cmake" => [:build, :test]

  def install
    # 2.5.0 requires CMake 3.10, so the policy floor for CMake 4 is gone,
    # and +p1 keeps std_cmake_args' relative CMAKE_INSTALL_LIBDIR relative.
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DLIB3MF_BUILD_SHARED=ON",
           "-DLIB3MF_TESTS=OFF",
           "-DUSE_INCLUDED_ZLIB=ON",
           "-DSTRIP_BINARIES=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Upstream installs its bindings under include/Bindings/<language>/;
    # the C++ header is include/Bindings/Cpp/lib3mf_implicit.hpp, and the
    # CMake target carries that directory for find_package users.
    (testpath/"test.cpp").write <<~CPP
      #include "lib3mf_implicit.hpp"
      #include <cstdio>
      int main() {
        auto wrapper = Lib3MF::CWrapper::loadLibrary();
        Lib3MF_uint32 major = 0, minor = 0, micro = 0;
        wrapper->GetLibraryVersion(major, minor, micro);
        auto model = wrapper->CreateModel();
        std::printf("%u.%u.%u\\n", major, minor, micro);
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp",
           "-I#{include}/Bindings/Cpp", "-L#{lib}",
           "-l3mf", "-o", "test"
    assert_match "2.5.0", shell_output("./test")

    # find_package(lib3mf) has to hand a consumer the installed headers and
    # library (before +p1 the config named a directory three levels above
    # itself and every CMake consumer failed at generate time). No C++
    # standard is set on purpose: the target exports cxx_std_11, and Apple
    # clang defaults to C++98.
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.16)
      project(lib3mftest CXX)
      find_package(lib3mf REQUIRED)
      add_executable(cmtest test.cpp)
      target_link_libraries(cmtest lib3mf::lib3mf)
    CMAKE
    system "cmake", "-S", ".", "-B", "cmbuild", "-DCMAKE_PREFIX_PATH=#{prefix}"
    system "cmake", "--build", "cmbuild"
    assert_match "2.5.0", shell_output("./cmbuild/cmtest")
  end
end
