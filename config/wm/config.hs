import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WallpaperSetter
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import System.IO
import Control.Applicative
import Data.List

main :: IO ()
main = do
  xmproc <- spawnPipe "xmobar" -- Enable xmobar
  xmonad $ ewmhFullscreen $ ewmh $ docks def
    { terminal        = "kitty" -- use Kitty terminal
    , borderWidth     = 0
    , layoutHook      = myLayoutHook
    , logHook         = dynamicLogWithPP xmobarPP
           { ppOutput = hPutStrLn xmproc
           , ppTitle  = xmobarColor "green" "" . shorten 50
           }
    , modMask         = mod4Mask     -- Rebind Mod to the Windows key
    } `additionalKeys`
    [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    , ((0, xK_Print), spawn "scrot") -- Screenshot
    ]

myManageHook = composeAll
  [ manageDocks
  , (isFullscreen --> doFullFloat)
  , ("Minecraft" `isPrefixOf`) <$> className --> doFullFloat
  ]

myLayoutHook = noBorders Full ||| noBorders (avoidStruts $ smartSpacing 4 $ layoutHook def)
