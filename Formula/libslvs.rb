class Libslvs < Formula
  desc "SolveSpace constraint solver library"
  homepage "https://github.com/solvespace/solvespace"
  # NOTE: the dots. GitHub release assets normalize "~" to "." in the stored
  # filename, so a URL written with a tilde 404s however correct the upload.
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/libslvs_3.2.git.20260908+p1.orig.tar.gz"
  # 3.2p1 = upstream 3.2 (master snapshot 2026-09-08) + HobbyCAD patch
  # series, level 1 against that snapshot.  The level counts releases
  # against ONE snapshot and restarts at a new one, so the snapshot and
  # the level together identify the contents.  This one carries the
  # nineteen-patch solver series (free parameter reporting, the #1769
  # rank fix, drag weights, curvature, rational cubics, tangent-angle and
  # curvature dimensions, operand validation, arc midpoint).  It is the
  # same tarball the Launchpad PPA builds libslvs 3.2.git~20260908+p1-1
  # from.
  #
  # The series is DELIVERED INSIDE THE TARBALL, so this formula applies no
  # patches at all. It used to fetch five patch files from a moving branch
  # (raw.githubusercontent.com/.../main/) at build time, each with its own
  # checksum; any of them moving or vanishing broke the build. Now there is
  # one pinned artifact.
  #
  # The series still exists as the record of what diverges from upstream, at
  # HobbyCAD-libs/solvespace/patch-series/, and make-orig.sh regenerates this
  # tarball from it reproducibly.
  version "3.2p1"
  sha256 "43276cfda2417e0fc0325c430a4a263325f46d7a2dd2794a881f8cf87bf937f8"
  license "GPL-3.0-only"

  depends_on "cmake" => :build
  depends_on "eigen"

  def install
    # Stub empty git submodule directories: the constraint solver
    # does not need any of these vendored libraries.
    %w[zlib libpng freetype cairo pixman angle].each do |submod|
      dir = buildpath/"extlib"/submod
      if dir.directory? && !(dir/"CMakeLists.txt").exist?
        (dir/"CMakeLists.txt").write("# stub: submodule not needed for libslvs\n")
      end
    end

    # Link Eigen headers into the expected extlib/eigen location
    eigen_dir = buildpath/"extlib/eigen"
    eigen_dir.mkpath
    (eigen_dir/"Eigen").make_symlink formula_opt_prefix("eigen")/"include/eigen3/Eigen"
    (eigen_dir/"unsupported").make_symlink formula_opt_prefix("eigen")/"include/eigen3/unsupported"

    # Override solvespace's set(CMAKE_CXX_STANDARD 11): the -D flag cannot
    # override a normal variable, so we must patch the source directly
    inreplace "CMakeLists.txt", "set(CMAKE_CXX_STANDARD 11)", "set(CMAKE_CXX_STANDARD 14)"

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
    # The header reports the HobbyCAD series level; a stock upstream
    # libslvs has no version macro at all, so this also proves the
    # installed header is the patched one.
    (testpath/"test.c").write <<~C
      #include <slvs.h>
      #include <stdio.h>
      #if !defined(SLVS_HOBBYCAD_PATCHLEVEL) || SLVS_HOBBYCAD_PATCHLEVEL < 1
      #error "not the HobbyCAD libslvs series"
      #endif
      int main() {
        Slvs_System sys = {};
        (void)sys;
        printf("%s\\n", SLVS_VERSION_STRING);
        return 0;
      }
    C
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lslvs", "-o", "test"
    assert_match "3.2p1", shell_output("./test")
  end
end
