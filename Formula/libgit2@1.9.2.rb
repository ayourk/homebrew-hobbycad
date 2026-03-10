# =====================================================================
#  HobbyCAD-homebrew — Formula/libgit2@1.9.2.rb — libgit2 1.9.2 (pinned)
# =====================================================================
#
#  Security release with SSH fixes.
#  See docs/dev_environment_setup.txt §6.4.
#
# =====================================================================
class Libgit2AT192 < Formula
  desc "C library for Git core methods"
  homepage "https://libgit2.org/"
  url "https://github.com/libgit2/libgit2/archive/refs/tags/v1.9.2.tar.gz"
  version "1.9.2"
  sha256 "6f097c82fc06ece4f40539fb17e9d41baf1a5a2fc26b1b8562d21b89bc355fe6"
  license "GPL-2.0-only" => { with: "GCC-exception-3.1" }

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libssh2"

  uses_from_macos "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
           "-DBUILD_TESTS=OFF",
           "-DBUILD_CLI=OFF",
           "-DUSE_SSH=ON"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      This is a version-pinned formula for HobbyCAD (security release 1.9.2).

      It is keg-only, so you must tell CMake where to find it:

        -DCMAKE_PREFIX_PATH=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"test.c").write <<~C
      #include <git2.h>
      #include <stdio.h>
      int main() {
        git_libgit2_init();
        int major, minor, rev;
        git_libgit2_version(&major, &minor, &rev);
        printf("libgit2 %d.%d.%d\\n", major, minor, rev);
        git_libgit2_shutdown();
        return 0;
      }
    C
    system ENV.cc, "test.c",
           "-I#{include}", "-L#{lib}",
           "-lgit2", "-o", "test"
    assert_match "1.9.2", shell_output("./test")
  end
end
