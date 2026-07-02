return {
    url = "https://github.com/HimadriChakra12/fetch.git", 
    targets = {
        default = {
            build = function()
                return os.execute("make")
            end,
            install = function()
                return os.execute("sudo make install")
            end,
            uninstall = function()
                return os.execute("sudo rm "..install_directories.bin.."/swat")
            end,
        },
    },
}
