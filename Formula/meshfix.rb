class Meshfix < Formula
  desc "Automatic repair of mesh models"
  homepage "https://github.com/MarcoAttene/MeshFix-V2.1"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/meshfix_2.1.git.20260208.orig.tar.gz"
  version "2.1"
  sha256 "27d135e85e320439df49d96c8de79042d2cbb524f9aa952eb7a8544571131fbf"
  license "GPL-3.0-or-later"

  depends_on "cmake" => :build

  # Cross-platform patch: separates library from CLI, adds CMake
  # package config.  The coordinates.h hunk is applied separately via
  # inreplace below because the upstream tarball uses CRLF line endings
  # in that file, which prevents the unified diff from matching.
  patch do
    url "https://raw.githubusercontent.com/ayourk/hobbycad-vcpkg/main/ports/meshfix/build-shared-library-homebrew.patch"
    sha256 "12145ca0d15b39e242c93fdce7555b0ab162073254a363a1e16e21454b93e2a6"
  end

  def install
    # Remove Apple-specific guard around cstdint include — the header is
    # available on all modern toolchains.  Applied via inreplace rather
    # than the patch above because coordinates.h has mixed CRLF/LF line
    # endings that cause the unified diff hunk to fail.
    inreplace "include/Kernel/coordinates.h",
              "#ifndef __APPLE__\r\n#include <cstdint>\r\n#endif",
              "#include <cstdint>"
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
           "-DMESHFIX_BUILD_SHARED=ON",
           "-DMESHFIX_BUILD_CLI=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <meshfix.h>
      int main() {
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp",
           "-I#{include}", "-L#{lib}",
           "-lmeshfix", "-o", "test"
    system "./test"
  end
end
