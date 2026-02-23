class Libslvs < Formula
  desc "SolveSpace constraint solver library"
  homepage "https://github.com/solvespace/solvespace"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/libslvs_3.2.git.20260208.orig.tar.gz"
  version "3.2"
  sha256 "89221ff3a92f9e4d59f61ca86cf82bb38cf313183be660fdd7b628da66790864"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "eigen"

  # Handle missing .git directory when building from tarball
  patch do
    url "https://raw.githubusercontent.com/ayourk/hobbycad-vcpkg/main/ports/libslvs/0001-handle-missing-git-directory.patch"
    sha256 "07c85c6f8b2468cce466675d9e1c58aa2cd5ddb6201a2ee75c124dafcd4d3182"
  end

  # Guard macOS solvespace target references behind ENABLE_GUI
  patch do
    url "https://raw.githubusercontent.com/ayourk/hobbycad-vcpkg/main/ports/libslvs/0002-guard-macos-solvespace-target-references.patch"
    sha256 "9fed7c85bf8e0bbc4cdb7584bfdbed89212ad2caec6b7c5531b7990191d34821"
  end

  def install
    # Stub empty git submodule directories — the constraint solver
    # doesn't need any of these vendored libraries.
    %w[zlib libpng freetype cairo pixman angle].each do |submod|
      dir = buildpath/"extlib"/submod
      if dir.directory? && !(dir/"CMakeLists.txt").exist?
        (dir/"CMakeLists.txt").write("# stub — submodule not needed for libslvs\n")
      end
    end

    # Link Eigen headers into the expected extlib/eigen location
    eigen_dir = buildpath/"extlib/eigen"
    eigen_dir.mkpath
    (eigen_dir/"Eigen").make_symlink Formula["eigen"].opt_prefix/"include/eigen3/Eigen"
    (eigen_dir/"unsupported").make_symlink Formula["eigen"].opt_prefix/"include/eigen3/unsupported"

    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DBUILD_LIB=ON",
           "-DENABLE_GUI=OFF",
           "-DENABLE_CLI=OFF",
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
