class Libslvs < Formula
  desc "SolveSpace constraint solver library"
  homepage "https://github.com/solvespace/solvespace"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/libslvs_3.2.git~20260208.orig.tar.gz"
  version "3.2"
  sha256 "89221ff3a92f9e4d59f61ca86cf82bb38cf313183be660fdd7b628da66790864"
  license "GPL-3.0-only"

  depends_on "cmake" => :build

  # Handle missing .git directory when building from tarball
  patch do
    url "https://raw.githubusercontent.com/ayourk/hobbycad-vcpkg/main/ports/libslvs/0001-handle-missing-git-directory.patch"
    sha256 "07c85c6f8b2468cce466675d9e1c58aa2cd5ddb6201a2ee75c124dafcd4d3182"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DBUILD_LIB=ON",
           "-DBUILD_GUI=OFF",
           "-DBUILD_CLI=OFF",
           "-DENABLE_OPENMP=OFF",
           "-DENABLE_TESTS=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <slvs.h>
      int main() {
        Slvs_System sys = {};
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lslvs", "-o", "test"
    system "./test"
  end
end
