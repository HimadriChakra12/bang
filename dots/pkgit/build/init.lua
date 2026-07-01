return {
  ["Makefile"] = {
    targets = {
      default = {
        build = function()
          return os.execute("make")
        end,
        install = function()
          return os.execute("make install PREFIX="..prefix)
        end,
        uninstall = function()
          return os.execute("make uninstall PREFIX="..prefix)
        end,
      },
      quiet = {
        build = function()
          return os.execute("make &>/tmp/pkgit_build.log")
        end,
        install = function()
          return os.execute("make install PREFIX="..prefix.." &>/tmp/pkgit_build.log")
        end,
        uninstall = function()
          return os.execute("make uninstall PREFIX="..prefix.." &>/tmp/pkgit_build.log")
        end,
      },
    }
  },
  ["meson.build"] = {
    targets = {
      default = {
        build = function()
          return os.execute("meson setup build --prefix "..prefix.." && meson compile -C build")
        end,
        install = function()
          return os.execute("cd build && meson install")
        end,
        uninstall = function()
          return os.execute("cd build && ninja uninstall")
        end,
      },
      quiet = {
        build = function()
          return os.execute("meson setup build --prefix "..prefix.." &>/tmp/pkgit_build.log && meson compile -C build &>/tmp/pkgit_build.log")
        end,
        install = function()
          return os.execute("cd build && meson install &>/tmp/pkgit_build.log")
        end,
        uninstall = function()
          return os.execute("cd build && ninja uninstall &>/tmp/pkgit_build.log")
        end,
      },
    }
  },
  ["CMakeLists.txt"] = {
    targets = {
      default = {
        build = function()
          return os.execute("cmake -B build && cmake --build build")
        end,
        install = function()
          return os.execute("cmake --build . --target install")
        end,
        uninstall = function()
          return os.execute("xargs rm < install_manifest.txt")
        end,
      },
      quiet = {
        build = function()
          return os.execute("cmake -B build &>/tmp/pkgit_build.log && cmake --build build &>/tmp/pkgit_build.log")
        end,
        install = function()
          return os.execute("cmake --build . --target install &>/tmp/pkgit_build.log")
        end,
        uninstall = function()
          return os.execute("xargs rm < install_manifest.txt &>/tmp/pkgit_build.log")
        end,
      },
    }
  },
}
