class Meshfix < Formula
  desc "Automatic repair of mesh models"
  homepage "https://github.com/MarcoAttene/MeshFix-V2.1"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/meshfix_2.1.git~20260208.orig.tar.gz"
  version "2.1"
  sha256 "27d135e85e320439df49d96c8de79042d2cbb524f9aa952eb7a8544571131fbf"
  license "GPL-3.0-or-later"

  depends_on "cmake" => :build

  # Cross-platform patch: separates library from CLI, adds CMake
  # package config, fixes cstdint include guard.
  patch do
    url "https://raw.githubusercontent.com/ayourk/hobbycad-vcpkg/main/ports/meshfix/build-shared-library-cross-platform.patch"
    sha256 "5982fcdb11251b0bec2b66ecbfbf37aa8593823906daa97b030afa02e6da2c4d"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
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
