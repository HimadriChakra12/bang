return {
    url = "https://github.com/HimadriChakra12/swat.git", 
    targets = {
        default = {
            build = function()
                return os.execute("make")
            end,
            install = function()
                return os.execute("bash install.sh")
            end,
            uninstall = function()
                return os.execute("sudo rm "..install_directories.bin.."/swat")
            end,
        },
    },
}
