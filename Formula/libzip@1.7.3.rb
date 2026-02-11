# Pinned to match Ubuntu 24.04 LTS (see docs/dev_environment_setup.txt §6.4)
class LibzipAT173 < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "https://github.com/nih-at/libzip/releases/download/v1.7.3/libzip-1.7.3.tar.gz"
  version "1.7.3"
  sha256 "0e2276c550c5a310d4ebf3a2c3dfc43fb3b4602a072ff625842ad4f3238cb9cc"
  license "BSD-3-Clause"

  keg_only :versioned_formula

  depends_on "cmake" => :build

  uses_from_macos "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DBUILD_TOOLS=OFF",
           "-DBUILD_EXAMPLES=OFF",
           "-DBUILD_DOC=OFF",
           "-DBUILD_REGRESS=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      This is a version-pinned formula for HobbyCAD (matching Ubuntu 24.04).

      It is keg-only, so you must tell CMake where to find it:

        -Dlibzip_DIR=#{opt_lib}/cmake/libzip

      Or add to CMAKE_PREFIX_PATH:

        -DCMAKE_PREFIX_PATH=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"test.c").write <<~C
      #include <zip.h>
      #include <stdio.h>
      int main() {
        printf("libzip %s\\n", zip_libzip_version());
        return 0;
      }
    C
    system ENV.cc, "test.c",
           "-I#{include}", "-L#{lib}",
           "-lzip", "-o", "test"
    assert_match "1.7.3", shell_output("./test")
  end
end
