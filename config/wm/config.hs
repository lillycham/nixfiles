import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Util.SpawnOnce
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WallpaperSetter
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.IO
import Control.Applicative
import Data.List

main :: IO ()
main = do
  xmonad . withSB myStatusBar . ewmhFullscreen . ewmh . docks $ def
    { terminal        = "kitty" -- use Kitty terminal
    , borderWidth     = 0
    , layoutHook      = myLayoutHook
    , modMask         = mod4Mask     -- Rebind Mod to the Windows key
    } `additionalKeys`
    [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    , ((0, xK_Print), spawn "scrot") -- Screenshot
    , ((mod4Mask, xK_c), toggleFloat)
    ]

myStatusBar = statusBarProp "xmobar" (pure xmobarPP)

myManageHook = composeAll
  [ manageDocks
  , (isFullscreen --> doFullFloat)
  , ("Minecraft" `isPrefixOf`) <$> className --> doFullFloat
  ]

myLayoutHook = noBorders ( avoidStruts
                         $ smartSpacing 4
                         $ layoutHook def
                         ) ||| noBorders Full

centreRect = W.RationalRect 0.25 0.25 0.5 0.5

-- If the window is floating then (f), if tiled then (n)
floatOrNot f n = withFocused $ \windowId -> do
    floats <- gets (W.floating . windowset)
    if windowId `M.member` floats -- if the current window is floating...
       then f
       else n

-- Centre and float a window (retain size)
centreFloat win = do
    (_, W.RationalRect x y w h) <- floatLocation win
    windows $ W.float win (W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h)
    return ()

-- Float a window in the centre
centreFloat' w = windows $ W.float w centreRect

-- Make a window my 'standard size' (half of the screen) keeping the centre of the window fixed
standardSize win = do
    (_, W.RationalRect x y w h) <- floatLocation win
    windows $ W.float win (W.RationalRect x y 0.5 0.5)
    return ()


-- Float and centre a tiled window, sink a floating window
toggleFloat = floatOrNot (withFocused $ windows . W.sink) (withFocused centreFloat')
