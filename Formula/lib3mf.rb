class Lib3mf < Formula
  desc "3D Manufacturing Format library"
  homepage "https://3mf.io/"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/lib3mf_2.4.1.git.20260208.orig.tar.gz"
  version "2.4.1"
  sha256 "469f4b8780ee4c369b695210611d70fc70e8e4b22da6ea97265f69c9a50828b1"
  license "BSD-2-Clause"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DLIB3MF_TESTS=OFF",
           "-DUSE_INCLUDED_ZLIB=ON"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <lib3mf/lib3mf_implicit.hpp>
      int main() {
        auto wrapper = Lib3MF::CWrapper::loadLibrary();
        auto model = wrapper->CreateModel();
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp",
           "-I#{include}", "-L#{lib}",
           "-l3mf", "-o", "test"
    system "./test"
  end
end
