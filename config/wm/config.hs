import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.WallpaperSetter
import System.IO

main :: IO () 
main = do
  xmproc <- spawnPipe "xmobar" -- Enable xmobar
  xmonad $ docks def
    { terminal    = "kitty" -- use Kitty terminal
    , startupHook = spawnOnce "feh --bg-fill ~/Pictures/macOS-Monterey-Dark.jpg"          -- invert scroll wheel, enable wallpaper
    , layoutHook  = avoidStruts $ smartSpacing 4 $ layoutHook def
    , borderWidth = 0
    , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                }
    , modMask = mod4Mask     -- Rebind Mod to the Windows key
    } `additionalKeys`
    [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    , ((0, xK_Print), spawn "scrot") -- Screenshot
    ]
