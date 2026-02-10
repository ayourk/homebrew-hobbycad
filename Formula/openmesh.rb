class Openmesh < Formula
  desc "Half-edge polygon mesh data structure"
  homepage "https://www.graphics.rwth-aachen.de/software/openmesh/"
  url "https://github.com/ayourk/hobbycad-vcpkg/releases/download/sources/libopenmesh_11.0.0.git~20260208.orig.tar.gz"
  version "11.0.0"
  sha256 "b6f0a3eb3078984ca651b6bf38a781a072049222f77bac1025101371fca18899"
  license "BSD-3-Clause"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build",
           *std_cmake_args,
           "-DBUILD_APPS=OFF",
           "-DOPENMESH_BUILD_SHARED=ON",
           "-DOPENMESH_DOCS=OFF",
           "-DOPENMESH_BUILD_UNIT_TESTS=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>
      typedef OpenMesh::TriMesh_ArrayKernelT<> MyMesh;
      int main() {
        MyMesh mesh;
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", "test.cpp",
           "-I#{include}", "-L#{lib}",
           "-lOpenMeshCore", "-o", "test"
    system "./test"
  end
end
