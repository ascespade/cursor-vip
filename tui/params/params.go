package params

var Version = 260

var Hosts = []string{"http://orcl.d.eiyou.fun:7193", "https://cursor.jeter.eu.org"}

//var Hosts = []string{"http://localhost:7193"}

var Host = Hosts[0]
var GithubPath = "https://github.com/kingparks/cursor-vip/"
var GithubDownLoadPath = "releases/download/latest/"
var GithubInstall = "i.sh"
var Green = "\033[32m%s\033[0m\n"
var Yellow = "\033[33m%s\033[0m\n"
var HGreen = "\033[1;32m%s\033[0m"
var DGreen = "\033[4;32m%s\033[0m\n"

// var Red = "\033[31m%s\033[0m\n"
var Red = "\033[1;31m%s\033[0m\n"
var DefaultColor = "%s"
var M3DaysRemainingOnTrial = "..."

var Product = []string{"cursor IDE", "cursor Pro", "cursor Enterprise", "cursor Ultimate"}
var IsOnlyMod2 = false
