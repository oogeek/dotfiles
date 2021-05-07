{-
   __   _____  ___                      _
   \ \ / /|  \/  |                     | |
    \ V / | .  . | ___  _ __   __ _  __| |
    /   \ | |\/| |/ _ \| '_ \ / _` |/ _` |
   / /^\ \| |  | | (_) | | | | (_| | (_| |
   \/   \/\_|  |_/\___/|_| |_|\__,_|\__,_|

-}

{-# LANGUAGE ParallelListComp #-}
import XMonad hiding ((|||))
import System.Directory
import System.Process
import System.IO (hPutStrLn, withFile, Handle)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.FindEmptyWorkspace
import XMonad.Actions.PreviousLayout
import XMonad.Actions.EasyMotion
import XMonad.Actions.UpdatePointer

import XMonad.Actions.CopyWindow hiding (wsContainingCopies, copiesPP)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.DynamicWorkspaces
import qualified XMonad.Actions.FlexibleManipulate as Flex
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.ShowText
import XMonad.Actions.OnScreen
import XMonad.Actions.CycleWS
import XMonad.Actions.TagWindows
import XMonad.Actions.WorkspaceNames
import XMonad.Actions.Plane
import XMonad.Actions.AfterDrag
import XMonad.Actions.MouseGestures
import XMonad.Actions.Commands
import XMonad.Actions.FloatKeys
import qualified XMonad.Actions.FlexibleResize as Flex
-- import qualified XMonad.Actions.DynamicWorkspaceOrder as DO
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.WindowBringer

-- Data
import Data.Char (isSpace, toUpper, chr, ord, isAlphaNum, isAscii, isDigit)
import Data.Maybe (fromJust, isJust, fromMaybe)
import Data.Monoid
import Data.Tree
import Data.Text (isInfixOf, pack)
import qualified Data.Map as M
import Data.Time.LocalTime
import Data.Time.Format
import Data.List.Split
import Data.Bool
import Data.Function (on)
import Data.List (intercalate, filter, nub, elemIndex)
import Data.Functor ((<&>))

-- Hooks
-- import XMonad.Hooks.DynamicLog (pad, dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.ManageDebug
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (docks, avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WallpaperSetter
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.XPropManage
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.DebugStack
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.DebugKeyEvents

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ImageButtonDecoration
import XMonad.Layout.Minimize
import XMonad.Layout.Maximize
import XMonad.Layout.TwoPane
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Accordion
import XMonad.Layout.WindowSwitcherDecoration
import XMonad.Layout.DraggingVisualizer
import XMonad.Layout.DecorationAddons
import XMonad.Layout.IndependentScreens
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||))

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Workspace
import XMonad.Prompt.AppendFile
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.Layout

-- import XMonad.Prompt.Ssh
import XMonad.Prompt.Unicode
import XMonad.Prompt.XMonad
import Control.Arrow (first, (&&&))
import Control.Monad

-- Utilities
import XMonad.Util.EZConfig 
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Paste (pasteSelection, sendKeyWindow, sendKey)
import XMonad.Util.Themes
import XMonad.Util.Timer (startTimer, handleTimer)
import XMonad.Util.Dmenu
import XMonad.Util.DebugWindow
import XMonad.Util.WorkspaceCompare
import XMonad.Util.NamedWindows
import XMonad.Util.Loggers
import XMonad.Util.Cursor (setDefaultCursor)

myFont :: String
myFont = "xft:Inter:bold:size=16:antialias=true:hinting=true"

myFont' :: String
myFont'= "xft:Inter:bold:size=26:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask

altMask :: KeyMask
altMask = mod1Mask         

myTerminal :: String
myTerminal = "kitty"

myBrowser :: String
myBrowser = "firefox "

myEditor :: String
myEditor = myTerminal ++ " sh -c vim "

myBorderWidth :: Dimension
myBorderWidth = 2

myNormColor :: String
myNormColor = "#282c34"  

myFocusColor :: String
myFocusColor = magenta 

clickableWindow :: Window -> String -> String
clickableWindow w = xmobarAction ("xdotool windowactivate " ++ show w) "1"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

wCount :: X Int
wCount = gets $ length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- current workspace name
cTag :: X (Maybe String)
cTag = gets $ Just . show . W.currentTag . windowset

-- cTag = gets $ Just . show . W.integrate' .  W.stack . W.workspace . W.current .windowset
eTag = withWindowSet (return . Just . showAll . W.stack . W.workspace . W.current) 
    where highlight = xmobarColor yellow "" 
          showAll w = show (integrateLL w) ++ highlight (show (integrateXX w)) ++ show (integrateRR w) 

integrateOthers :: W.Stack a -> [a]
integrateOthers (W.Stack x l r) = reverse l ++ r

integrateL (W.Stack x l r) = reverse l
integrateX (W.Stack x l r) = [x]
integrateR (W.Stack x l r) = r

integrateLL :: Maybe (W.Stack a) -> [a]
integrateLL = maybe [] integrateL 
integrateXX = maybe [] integrateX
integrateRR = maybe [] integrateR

killOthers :: X()
killOthers = withOthers killWindow 

withOthers :: (Window -> X ()) -> X()
withOthers f = withWindowSet $ \ws -> let others = maybe [] integrateOthers . W.stack . W.workspace . W.current $ ws
                                      in forM_ others f
showWsName :: X ()
showWsName = cTag>>= (\input->spawn ("dunstify -t 2000 -u normal "++" "++(words . show $ input)!!1))

myStartupHook :: X ()
myStartupHook = do
    return () 
    checkKeymap myConfig' myKeys
    ewmhDesktopsStartup 
    spawn "/home/oogeek/scripts/wallnext.sh"
    spawnOnce "picom &"
    spawnOnce "fcitx5 &" 
    spawn "/home/oogeek/scripts/monitor-primary.sh"
    spawnOnce "sudo cpupower frequency-set -g performance"
    spawn "ps axo pid,s,command | awk '/alsactl monitor default$/ {print $1}' | xargs --no-run-if-empty kill"
    spawnOnce "/usr/bin/aa-notify -p -s 1  -f /var/log/audit/audit.log"
    spawn "wmname LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                 (0xE6,0x3E,0x3E) -- lowest inactive bg
                 (0x19,0x15,0x6E) -- highest inactive bg
                 (0xFF,0xFF,0x00) -- active bg
                 white            -- inactive fg
                 black            -- active fg
    where black = minBound
          white = maxBound

mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 90
    , gs_cellwidth    = 400
    , gs_cellpadding  = 10
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont'
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 90
                   , gs_cellwidth    = 400
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont'
                   }

myAppGrid = [ ("Audacity", "audacity")
            , ("MPV", "mpv")
            , ("Firefox", "firefox")
            , ("Firefox-Beta", "firefox-beta")
            , ("Firefox-Nightly", "firefox-nightly")
            , ("Chromium", "chromium")
            , ("Google-Chrome", "google-chrome-stable")
            , ("LibreOffice Impress", "loimpress")
            , ("LibreOffice Writer", "lowriter")
            , ("PCManFM", "pcmanfm")
            ]

screenshotPath :: String
screenshotPath = "~/scrot/%Y-%m-%d-%H-%M-%S-scrot.png"
-- I don't use these anymore, but I leave it here.
treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
   [ Node (TS.TSNode "+ Accessories" "Accessory applications" (return ()))
     []         
   , Node (TS.TSNode "+ Screenshots" "take a screenshot" (return ()))
       [ Node (TS.TSNode "Quick fullscreen" "take screenshot immediately" (spawn $ "scrot -q 100 -d 1 " ++ screenshotPath)) []
       , Node (TS.TSNode "Delayed fullscreen" "take screenshot in 5 secs" (spawn $ "scrot -q 100 -d 5 " ++ screenshotPath)) []
       , Node (TS.TSNode "Section screenshot" "take screenshot of section" (spawn $ "scrot -q 100 -s " ++ screenshotPath)) []
       ]
   , Node (TS.TSNode "------------------------" "" (spawn "xdotool key Escape")) []
   , Node (TS.TSNode "+ XMonad Controls" "window manager commands" (return ()))
       [ Node (TS.TSNode "+ View Workspaces" "View a specific workspace" (return ()))
         [ Node (TS.TSNode "View 1" "View workspace 1" (spawn "~/.xmonad/xmonadctl 1")) []
         , Node (TS.TSNode "View 2" "View workspace 2" (spawn "~/.xmonad/xmonadctl 3")) []
         ]

       , Node (TS.TSNode "+ Shift Workspaces" "Send focused window to specific workspace" (return ()))
         [ Node (TS.TSNode "View 1" "View workspace 1" (spawn "~/.xmonad/xmonadctl 2")) []
         , Node (TS.TSNode "View 2" "View workspace 2" (spawn "~/.xmonad/xmonadctl 4")) []
         ]
       ]
   ]

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig 
    { TS.ts_hidechildren = True
    , TS.ts_background   = 0xdd282c34
    , TS.ts_font         = myFont'
    , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24)
    , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34)
    , TS.ts_highlight    = (0xffffffff, 0xff755999)
    , TS.ts_extra        = 0xffd0d0d0
    , TS.ts_node_width   = 400
    , TS.ts_node_height  = 40
    , TS.ts_originX      = 100
    , TS.ts_originY      = 100
    , TS.ts_indent       = 80
    , TS.ts_navigate     = myTreeNavigation
    }

myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    , ((0, xK_r),        TS.moveTo ["+ Screenshots"])
    , ((mod4Mask, xK_v), TS.moveTo ["+ Bookmarks", "+ Vim"])
    , ((mod4Mask .|. altMask, xK_a), TS.moveTo ["+ Bookmarks", "+ Linux", "+ Arch Linux"])
    ]

myXPConfig :: XPConfig
myXPConfig = def
    { font                = myFont
    , bgColor             = "#282a36"
    , fgColor             = "#f8f8f2"
    , fgHLight            = "#ffffff"
    , bgHLight            = "#ff79c6"
    , borderColor         = magenta
    , promptBorderWidth   = 1
    , promptKeymap        = myXPKeymap
    , position            = Top
    , height              = 40
    , historySize         = 10
    , historyFilter       = id
    , defaultText         = []
    , autoComplete        = Just 100000  -- set Just 100000 for .1 sec
    , showCompletionOnTab = False
    , searchPredicate     = fuzzyMatch
    , defaultPrompter     = map toUpper  -- change prompt to UPPER
    , alwaysHighlight     = True
    , maxComplRows        = Just 10
    }

myXPConfig' :: XPConfig
myXPConfig' = myXPConfig
    { autoComplete        = Nothing
    }

-- calculator Prompt
calcPrompt c ans =
    inputPrompt c (trim ans) ?+ \input ->
        liftIO(runProcessWithInput "qalc" [input] "") >>= calcPrompt c
    where
        f = reverse . dropWhile isSpace
        trim  = f . f

myXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
myXPKeymap = M.fromList $
    map (first $ (,) controlMask)      -- control + <key>
    [ (xK_z, killBefore)               -- kill line backwards
    , (xK_k, killAfter)                -- kill line forwards
    , (xK_a, startOfLine)              -- move to the beginning of the line
    , (xK_e, endOfLine)                -- move to the end of the line
    , (xK_m, deleteString Next)        -- delete a character foward
    , (xK_b, moveCursor Prev)          -- move cursor forward
    , (xK_f, moveCursor Next)          -- move cursor backward
    , (xK_BackSpace, killWord Prev)    -- kill the previous word
    , (xK_y, pasteString)              -- paste a string
    , (xK_g, quit)                     -- quit out of prompt
    , (xK_bracketleft, quit)
    ]
    ++
    map (first $ (,) altMask)          -- meta key + <key>
    [ (xK_BackSpace, killWord Prev)    -- kill the prev word
    , (xK_f, moveWord Next)            -- move a word forward
    , (xK_b, moveWord Prev)            -- move a word backward
    , (xK_d, killWord Next)            -- kill the next word
    , (xK_n, moveHistory W.focusUp')   -- move up thru history
    , (xK_p, moveHistory W.focusDown') -- move down thru history
    ]
    ++
    map (first $ (,) 0) -- <key>
    [ (xK_Return, setSuccess True >> setDone True)
    , (xK_KP_Enter, setSuccess True >> setDone True)
    , (xK_BackSpace, deleteString Prev)
    , (xK_Delete, deleteString Next)
    , (xK_Left, moveCursor Prev)
    , (xK_Right, moveCursor Next)
    , (xK_Home, startOfLine)
    , (xK_End, endOfLine)
    , (xK_Down, moveHistory W.focusUp')
    , (xK_Up, moveHistory W.focusDown')
    , (xK_Escape, quit)
    ]

-- SearchEngine
archwiki, ebay, news, reddit, urban, thesaurus :: S.SearchEngine

archwiki  = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
ebay      = S.searchEngine "ebay" "https://www.ebay.com/sch/i.html?_nkw="
news      = S.searchEngine "news" "https://news.google.com/search?q="
reddit    = S.searchEngine "reddit" "https://www.reddit.com/search/?q="
urban     = S.searchEngine "urban" "https://www.urbandictionary.com/define.php?term="
thesaurus = S.searchEngine "thesaurus" "https://www.thesaurus.com/browse/"

-- XMonad.Actions.Search
searchList :: [ (String, S.SearchEngine) ]
searchList = 
    [ ("a", archwiki)
    , ("d", S.duckduckgo)
    , ("e", ebay)
    , ("g", S.google)
    , ("i", S.images)
    , ("r", reddit)
    , ("t", thesaurus)
    , ("v", S.vocabulary)
    , ("w", S.wikipedia)
    , ("y", S.youtube)
    ]

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myTabTheme = def 
    { fontName            = myFont
    , activeColor         = black
    , inactiveColor       = black
    , activeBorderColor   = purple
    , inactiveBorderColor = black
    , activeBorderWidth   = 0
    , inactiveBorderWidth = 0
    , activeTextColor     = magenta
    , inactiveTextColor   = white
    }

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 0.3
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-- shift a window to a specific workspace
promptedShift :: X ()
promptedShift = workspacePrompt myXPConfig $ windows . W.shift

-- prompt to ask for file path
-- along with completion
filePathPrompt = inputPromptWithCompl myXPConfig "file path" filePathCompletion
filePathCompletion = mkComplFunFromList myXPConfig ["/home/oogeek/Notes", "/home/oogeek/learn.txt"]

-- show Workspce History
showWsHistory :: X ()
showWsHistory = workspaceHistory >>= sendNoti . show

browserPrompt :: X ()
browserPrompt = inputPromptWithCompl myXPConfig "Browser" browserComp ?+ \url -> spawn (myBrowser ++ " "++url)
browserComp = mkComplFunFromList myXPConfig ["www.youtube.com", "wiki.archlinux.org", "www.github.com", "aur.archlinux.org", " www.duckduckgo.com"]

takeNote :: X ()
takeNote = do 
    date <- io $ fmap (formatTime defaultTimeLocale "[%Y-%m-%d %H:%M] ") getZonedTime 
    filePathPrompt ?+ \path->appendFilePrompt' myXPConfig (date ++) path

-- send a notification
sendMaybeNoti :: Maybe String -> X ()
sendMaybeNoti w = spawn ("dunstify -t 2000 -u normal "++" "++ maybe "Nothing" show w)

sendNoti :: String -> X ()
sendNoti w = spawn ("dunstify -t 2000 -u normal " ++ " " ++ w)

-- show some debug info of a window
showWinInfo :: Window->X ()
showWinInfo w = debugWindow w >>= sendNoti . show 

showDisplay :: X ()
showDisplay = asks display >>= sendNoti . show

showWinInfo' :: X ()
showWinInfo' = withFocused showWinInfo

trace' :: String -> IO ()
trace' = io . writeFile "girlfriendcaps.txt"

-- show window id, as the name suggests
showWindowID :: X ()
showWindowID = withFocused (\input->spawn ("dunstify -t 2000 -u normal "++" "++show input))

-- show stack information in a workspace
showWsStackInfo = withWindowSet (return . show . W.integrate' . W.stack . W.workspace . W.current) >>= sendNoti  

showWsStackInfo' = withWindowSet (return . show . W.stack . W.workspace . W.current) >>= sendNoti  

showWs :: X ()
showWs = asks config >>= sendNoti . concat . workspaces'
    where workspaces' = nub . workspaces

-- append new workspaces
appendWorkspacePrompt' :: X ()
appendWorkspacePromptComp = mkComplFunFromList myXPConfig ["reddit"]
appendWorkspacePrompt' = do
    (Just input) <- inputPromptWithCompl myXPConfig' "Add workspace name:" appendWorkspacePromptComp 
    (S sc) <- gets (W.screen . W.current . windowset) 
    appendWorkspace (show sc ++ "_" ++ input)

showScreenId :: ScreenId -> String
showScreenId (S sc) = show sc

-- Layout --
-- myl = imageButtonDeco shrinkText defaultThemeWithImageButtons myafter
myl = myLayoutHook
-- myl = draggingVisualizer myLayoutHook

-- myl = myshowL
-- myl = myvisualL
-- myvisualL = windowSwitcherDecoration shrinkText def (draggingVisualizer myLayoutHook)
-- myl = myafter
-- myshowL = showWName' myShowWNameTheme myLayoutHook 

-- myMagicFocus = magicFocus myLayoutHook
myLayoutHook = renamed [KeepWordsRight 1]
                 . avoidStruts 
                 . mouseResize 
              -- $ T.toggleLayouts floats
                 . mkToggle (NBFULL ?? NOBORDERS ?? EOT) 
                 $ myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| Accordion
                                 ||| tp
                                 ||| tc

keypad = ["<KP_End>", "<KP_Down>", "<KP_Page_Down>", "<KP_Left>", "<KP_Begin>", "<KP_Right>", "<KP_Home>", "<KP_Up>", "<KP_Page_Up>" ]
keypad'' = ["KP_End", "KP_Down", "KP_Page_Down", "KP_Left", "KP_Begin", "KP_Right", "KP_Home", "KP_Up", "KP_Page_Up" ]
keypad' = ["KP_1","KP_2","KP_3","KP_4","KP_5","KP_6","KP_7","KP_8","KP_9"]
keypadInd = M.fromList $ zip myWorkspaces keypad''

myWorkspaces' = map show [1..5]
myWorkspaces = ["sys", "dev", "www", "doc", "git", "libre", "file", "vid", "vbox", "fox", "ssh", "irc", "chat"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
    composeAll . concat $
    [ [isFullscreen --> doFullFloat]
    , [className =? b --> doShift "0_www"   | b <- myClassWeb]
    , [className =? c --> doShift "0_chat"  | c <- myClassChat]
    , [className =? c --> doShift "0_dev"   | c <- myClassDev]
    , [className =? c --> doShift "0_vid"   | c <- myClassMedia]
    , [className =? c --> doShift "0_fox"   | c <- myClassFox]
    , [className =? c --> doShift "0_doc"   | c <- myClassDoc]
    , [className =? c --> doShift "0_libre" | c <- myClassLibre]
    , [className =? c --> doShift "0_file"  | c <- myClassFile]
    , [className =? c --> doShift "0_vbox"  | c <- myClassVirt]
    , [className =? "mpv" --> customFloating (W.RationalRect 0.01 0.68 0.3 0.3)]
    , [className =? "VirtualBox Manager"    --> doFloat]
    , [(className =? "firefox" <&&> resource =? "Dialog") --> doFloat]
    ]
  
  where
    myClassWeb = ["Google-chrome", "Brave-browser", "Chromium", "firefox", "Microsoft-edge-dev" ]
    myClassChat = ["TelegramDesktop"]
    myClassDev = ["Emacs", "code-oss"]
    myClassVirt = ["VirtualBox Manager"] 
    myClassMedia = ["mpv", "vlc", "Droidcam"]
    myClassFox = ["gimp", "Firefox Beta"]
    myClassLibre = ["Soffice"]
    myClassDoc = ["Foxit Reader", "Zathura", "Wpp"]
    myClassFile = ["Thunar", "Pcmanfm", "dolphin"]

sxmobar0 = spawnStatusBarAndRemember "xmobar -x 0  ~/.config/xmobar/xmobarrct0" 
sxmobar1 = spawnStatusBarAndRemember "xmobar -x 1  ~/.config/xmobar/xmobarrct1" 

sxmobar2 = spawnStatusBarAndRemember "xmobar -x 0  ~/.config/xmobar/xmobarrcts0" 
sxmobar3 = spawnStatusBarAndRemember "xmobar -x 1  ~/.config/xmobar/xmobarrcts1" 

myXpropHook = xPropManageHook xPropMatches
xPropMatches :: [XPropMatch]
xPropMatches = [ 
    ([ (wM_CLASS, any (\w->pack "Gimp"`isInfixOf` pack w))], \w -> float w >> return (W.shift "0_file"))
 -- ([ (wM_COMMAND, any ("screen" ==)), (wM_CLASS, any ("xterm" ==))], pmX (addTag "screen"))
    , ([ (wM_CLASS, any (\w-> pack "LibreOffice" `isInfixOf` pack w))], pmP (W.shift "0_libre"))
    , ([ (wM_NAME, any (\w-> pack "LibreOffice" `isInfixOf` pack w))], pmP (W.shift "0_libre"))
               ]

myFadeHook = composeAll [ isUnfocused --> transparency 1.0, opaque ]

wLayout :: X ()
wLayout = do
    slayout <- gets (description . W.layout . W.workspace . W.current . windowset)
    pure slayout >>= sendNoti

myMouse = [ ((mod4Mask, button3), \w -> focus w >> Flex.mouseResizeWindow w >> ifClick (windows $ W.float w $ W.RationalRect 0 0 1 1))]

-- set layout of all workspaces to the layout of the current workspace
setAllLayout :: Layout Window -> X ()
setAllLayout ll = do
    ss@W.StackSet { W.current = c@W.Screen { W.workspace = ws}, W.visible = sVisible, W.hidden = sHidden}<- gets windowset 
    handleMessage (W.layout ws) (SomeMessage ReleaseResources)
    windows $ const $ ss {W.current = c { W.workspace = ws { W.layout = ll }}, W.visible = setSL sVisible, W.hidden = setHL sHidden}
        where setHL :: [W.Workspace i (Layout Window) a]->[W.Workspace i (Layout Window) a]
              setHL s = map (\w -> w{W.layout = ll}) s
              setSL :: [W.Screen WorkspaceId (Layout Window) Window ScreenId ScreenDetail]->[W.Screen WorkspaceId (Layout Window) Window ScreenId ScreenDetail]
              setSL = map (\w-> w{W.workspace = (W.workspace w){W.layout = ll}}) 

myKeys :: [ (String, X ()) ]
myKeys = [ 
          ("M-C-r", spawn "/home/oogeek/scripts/xmonad-recompile.sh")
        , ("M-S-r", spawn "xmonad --restart")   
        , ("M-S-q", confirmPrompt myXPConfig "exit" $ io exitSuccess) 
        , ("M1-<Tab>", cycleRecentNonEmptyWS [xK_Alt_L] xK_Tab xK_grave)
        -- use left Alt Tab and '`~' key on the top left

    -- Wallpaper
        , ("M1-l", spawn "/home/oogeek/scripts/wallnext.sh")
        , ("M1-t", spawn "/home/oogeek/scripts/walltaste.sh")
        , ("M1-n", spawn "/home/oogeek/scripts/wallpaper-taste-choice.sh")
        , ("M1-e", spawn "/home/oogeek/scripts/wallemergency.sh")
        , ("M1-r", spawn "/home/oogeek/scripts/wallremove.sh")

    -- Terminal
        , ("M-<Return>", spawn (myTerminal ++ " zsh"))
        , ("M1-<Return>", spawn ("alacritty" ++ " -e zsh"))
    
    -- Screenshot 
        , ("M1-s", spawn "/home/oogeek/scripts/screenshot-monitor.sh")
        , ("M1-S-s", spawn "flameshot gui")
        , ("M1-S-o", spawn "/home/oogeek/scripts/screenshot.sh")

    -- Sound 
        , ("M1-S-u", spawn "pamixer -i 5")
        , ("M1-S-p", spawn "pamixer -d 5")
        , ("M1-S-m", spawn "pamixer -t")
    
    -- Prompt
        ,("M-S-<Return>", shellPrompt myXPConfig') -- Xmonad Shell Prompt
        ,("M-M1-<Return>", spawn " ~/.config/rofi/launchers/colorful/launcher.sh") -- rofi

    -- Other Prompts
        , ("M-p c", calcPrompt myXPConfig' "qalc") -- calcPrompt
        , ("M-p m", manPrompt myXPConfig')          -- manPrompt
        , ("M-p x", xmonadPrompt myXPConfig')       -- xmonadPrompt
        , ("M-p w", spawn "/home/oogeek/scripts/window-properties.sh")
        
    -- Emoji
        , ("M1-C-o", spawn "rofimoji -a copy")

    -- Window Menu
        , ("M-o", bringMenuArgs' "rofi" ["-dmenu"])

    -- Aur
        , ("M-M1-u", spawn "/home/oogeek/scripts/aurcheck.sh")
        
    -- Disk Temp
        , ("M-M1-t", spawn "/home/oogeek/scripts/hddtemp.sh")

    -- Dunst notification
        , ("M1-c", spawn "dunstctl close-all" )
        , ("M1-p", spawn "dunstctl history-pop")

    -- Workspaces
        , ("M-.", nextScreen)  -- Switch focus to next monitor
        , ("M-,", prevScreen)  -- Switch focus to prev monitor
        , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)
        , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)
        , ("M-<Left>", moveTo Prev nonEmpty)
        , ("M-<Right>", moveTo Next nonEmpty)
        
    -- Firefox
     -- , ("M-u", sendKey altMask xK_1 )
     -- , ("M-u", getWinInfo')
     -- , ("M-u", showWindowID)
     -- , ("M-v", dTag)
     -- , ("M-u", showWs)
     -- , ("M-u", viewEmptyWorkspace)
     -- , ("M-v", wLayout)
        , ("M-v", setAllLayout =<< gets (W.layout . W.workspace . W.current . windowset))
        , ("M-r", cleanupStatusBars *> sxmobar0 *> sxmobar1 *> sxmobar2 *> sxmobar3) 
        , ("M-u", selectWindow def >>= (`whenJust` windows . W.focusWindow))
        , ("M-S-<F1>", showDisplay)
        , ("M-b", browserPrompt)

    -- Url to Qrcode
        , ("M-S-u", spawn "/home/oogeek/scripts/qrcode.sh")

    -- Floating windows
    --  , ("M-f", sendMessage (T.Toggle "floats")) 
        , ("M-t", withFocused $ windows . W.sink)  
        , ("M-S-t", sinkAll)                       

    -- Increase/decrease spacing (gaps)
        , ("M-<KP_Subtract>", decWindowSpacing 4) 
        , ("M-<KP_Add>", incWindowSpacing 4)      
        , ("M-M1-<KP_Subtract>", decScreenSpacing 4)
        , ("M-M1-<KP_Add>", incScreenSpacing 4)     

    -- Grid Select 
        , ("C-g g", spawnSelected' myAppGrid)      
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  
        , ("C-g b", bringSelected $ mygridConfig myColorizer) 

    -- Tree Select
        , ("C-t t", treeselectAction tsDefaultConfig)
  
    -- Screen-Locking
        , ("C-M1-l", spawn "XSECURELOCK_NO_COMPOSITE=1 XSECURELOCK_PASSWORD_PROMPT='time_hex' xsecurelock" )

    -- Tag
        , ("M-C-a", tagPrompt myXPConfig' $ withFocused . addTag)
        , ("M-C-h", tagPrompt myXPConfig' (`withTaggedGlobalP` shiftHere))
        , ("M-C-d", tagDelPrompt myXPConfig)
        , ("M-C-t", tagPrompt myXPConfig  focusUpTaggedGlobal)
        , ("M-C-f", tagPrompt myXPConfig (`withTaggedGlobal` float))
        , ("M-C-n", takeNote)
        , ("M1-C-d", removeEmptyWorkspace)
        , ("M1-C-s", selectWorkspace myXPConfig)
        , ("M1-C-c", withWorkspace myXPConfig (windows . copy))
        , ("M1-C-r", XMonad.Actions.DynamicWorkspaces.renameWorkspace myXPConfig')
        , ("M1-C-a", appendWorkspacePrompt')
        , ("M-C-w", promptedShift)
        , ("M-C-c", xmonadPrompt myXPConfig')

    -- Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-j", windows W.focusDown)    -- Move focus to the next window
        , ("M-k", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- Kill windows
        , ("M-S-c", kill1)     -- Kill the currently focused client
        , ("M-S-z", killAll)   -- Kill all windows on current workspace
        , ("M-S-x", killOthers)   -- Kill all windows on current workspace

    -- Windows Copy
        , ("M-0", windows copyToAll)
        , ("M-<F1>", copyWindowTo 1)
        , ("M-<F2>", copyWindowTo 2)
        , ("M-<F3>", copyWindowTo 3)
        , ("M-<F4>", copyWindowTo 4)
        , ("M-<F5>", copyWindowTo 5)
        , ("M-<F6>", copyWindowTo 6)
        , ("M-<F7>", copyWindowTo 7)
        , ("M-<F8>", copyWindowTo 8)
        , ("M-<F9>", copyWindowTo 9)
        , ("M-C-S-k", killAllOtherCopies) 

    -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL))  -- Toggles noborder/full
        , ("M-S-<Space>", sendMessage ToggleStruts)     -- Toggles struts
        , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder

    -- Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
        , ("M-C-<Up>", increaseLimit)                   -- Increase number of windows
        , ("M-C-<Down>", decreaseLimit)                 -- Decrease number of windows

    -- Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        , ("M-M1-k", sendMessage MirrorExpand)          -- Expand vert window width
        , ("M-M1-e", sendMessage (ResizeRatio 0.5))
        , ("M-M1-f", sendMessage (ResizeRatio (1/3)))

    ]

    -- X-selection-paste buffer
        ++ [("M-s" ++ " "  ++ k, S.promptSearch myXPConfig' f) | (k,f) <- searchList ]
        ++ [("M-S-s" ++ " " ++ k, S.selectSearch f) | (k,f) <- searchList ]
        ++ [("M-S-" ++ i, withNthWorkspaceScreen W.shift j) | (i,j) <- zip keypad [0..]]
        ++ [("M-" ++ i, withNthWorkspaceScreen W.view j) | (i,j) <- zip keypad [0..]]
        ++ [("M1-" ++ i, withNthWorkspaceScreen W.view j) | (i,j)<-zip keypad [9..]]
    --  ++ [("M-C-" ++ show k, windows $ XMonad.Actions.SwapWorkspaces.swapWithCurrent i) | (i, k) <- zip [xK_1 ..]]
        ++ [("M1-S-" ++ i, withNthWorkspaceScreen W.shift j) | (i,j) <- zip keypad [9..]]
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmpty        = WSIs (return (isJust . W.stack))
            --  nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

-- LAYOUT --

-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.

tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 8
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []

tp       = renamed [Replace "TP"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ TwoPane (3/100) (1/2) 

tc       = renamed [Replace "TC"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ ThreeColMid 1 (3/100) (1/2)

floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme                            
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat

grid     = renamed [Replace "grid"]                                   
           $ windowNavigation                                         
           $ addTabs shrinkText myTabTheme                            
           $ subLayout [] (smartBorders Simplest)                     
           $ limitWindows 12                                          
           $ mySpacing 0                                              
           $ mkToggle (single MIRROR)                                 
           $ Grid (16/10)                                             

spirals  = renamed [Replace "spirals"]                                
           $ windowNavigation                                         
           $ addTabs shrinkText myTabTheme                            
           $ subLayout [] (smartBorders Simplest)                     
           $ mySpacing' 8                                             
           $ spiral (6/7)                                             

tabs     = renamed [Replace "tabs"]                                   
           $ tabbed shrinkText myTabTheme

-- | 'currentWorkspaces' takes a 'PhysicalWindowSpace' sorting function, the workspaces on 
-- current screen and returns the sorted results. Can be used by other integration functions later.
currentWorkspaces :: ([PhysicalWindowSpace] -> [PhysicalWindowSpace]) -> X [PhysicalWorkspace]
currentWorkspaces pSort = do 
    winset <- gets windowset
    let ws    = pSort . W.workspaces $ winset
        sc    = W.screen . W.current $ winset
        wsOn  = workspacesOn sc ws
    return $ map W.tag wsOn

copyWindowTo :: Int -> X ()
copyWindowTo j = do
    sort <- getSortByIndex
    wsID <- currentWorkspaces sort
    windows $ copy $ wsID !! (j - 1)

wsContainingCopies :: X [WorkspaceId]
wsContainingCopies = do
    ws <- gets windowset
    let sc = W.screen . W.current $ ws
    return $ copiesOfOn (W.peek ws) (taggedWindows $ workspaceHidden ws sc)
  where
    workspaceHidden ws sc = [ w | w <- W.hidden ws, sc == unmarshallS (W.tag w) ]

withNthWorkspaceScreen :: (WorkspaceId -> WindowSet -> WindowSet) -> Int -> X ()
withNthWorkspaceScreen job wnum = do
    sort <- getSortByIndex
    cws <- currentWorkspaces sort
    let enoughWorkspaces = drop wnum cws
    case enoughWorkspaces of
         (w : _) -> windows $ job w
         []      -> return ()

-- make workspaces <=9 clickable 
-- super + number
clickable ws num = "<action=xdotool key super+"++show key++">"++" "++ws++" "++"</action>"
    where key = keypad'' !! num
     
-- make workspaces > 9 clickable 
-- alt + number
clickable' ws num = "<action=xdotool key alt+"++show key++">"++" "++ws++" "++"</action>"
    where key = keypad'' !! num

-- convert '<action ...> <fc...>[www]</fc> </action>' into '<action ...> <fc...>[ www ]</fc> </action>' 
check :: String -> String
check a 
    | (len>12) && any (\n -> n !! 12 =='[') [a] = take 12 a ++ "[ "++ take (len-19) ( drop 13 a) ++" ]" ++ "</fc>" 
    | otherwise = a
        where len = length a

ppp (ws:l:t:ex)
    | len <= 9  = wl:ex
    | otherwise = wf:ex
        where len = length (words ws)
              wl  = unwords [ clickable (check a) b  | (a, b) <- zip (words ws) [0..8]]
              wr  = unwords [ clickable' (check a) b | (a, b) <- zip (drop 9 (words ws)) [0..]]
              wf  = wl ++ xmobarColor white "" " • " ++ wr

checkNSP :: String -> String
checkNSP ws = unwords . filter (/= "NSP") $ words ws

checkNSP' :: [String] -> [String]
checkNSP' = filter (/= "NSP")  

-- XMobar config
constructXmobarConfig :: ScreenId -> PP
constructXmobarConfig s = myXmobarConfig {ppExtras = [windowCount, eTag, (fmap . fmap) colorGreen (logLayoutOnScreen s), (fmap . fmap) (colorMagenta . shorten 40) (logTitleOnScreen s)]}

myXmobarConfig          = xmobarPP {
      ppCurrent         = colorGreen . wrap "[" "]" 
    , ppVisible         = colorPurple          
    , ppHidden          = colorYellow . wrap "^" "^" 
    , ppHiddenNoWindows = colorPurple
    , ppVisibleNoWindows= Just (colorWhite . wrap "[" "]")
    , ppUrgent          = colorRed . wrap "!" "!" 
    , ppSep             = "<fc=white> | </fc>"      
    , ppWsSep           = " "
    , ppTitle           = colorCyan . shorten 50 
    , ppTitleSanitize   = xmobarStrip 
    , ppLayout          = colorMagenta . last . words 
    , ppOrder           = ppp 
    , ppSort            = getSortByIndex
}

{-_   _   _   _   _   _
 / \ / \ / \ / \ / \ / \
( c | o | l | o | r | s )
 \_/ \_/ \_/ \_/ \_/ \_/
-}
-- Colors
black   = "#21222c"
red     = "#ff5555" 
green   = "#50fa7b"
yellow  = "#f1fa8c" 
blue    = "#bd93f9"
magenta = "#ff79c6"
cyan    = "#8be9fd" 
white   = "#f8f8f2"
lowWhite = "#bbbbbb"
orange  = "#ffb86c" 
purple  = "#bd9cf9" 

colorBlack = xmobarColor black ""
colorRed   = xmobarColor red ""
colorGreen = xmobarColor green ""
colorYellow = xmobarColor yellow ""
colorBlue = xmobarColor blue ""
colorMagenta = xmobarColor magenta ""
colorCyan = xmobarColor cyan ""
colorWhite = xmobarColor white ""
colorOrange = xmobarColor orange ""
colorPurple = xmobarColor purple ""

myConfig' = myConfig 
    `additionalKeysP` myKeys 
    `removeKeysP` ["M-S-" ++ [n] | n <- ['1'..'9']] 
    `removeKeysP` ["M-" ++ [n] | n <- ['1'..'9']] 
    `additionalKeysP` [("M-S-4",spawn "killall picom; sleep 1; picom&")] 
    -- `additionalMouseBindings` myMouse 

        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        
myConfig = def { 
    manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook  <+> manageDocks <+> myXpropHook
    , handleEventHook    = serverModeEventHookCmd
                           <+> debugKeyEvents
                           <+> handleTimerEvent
                           <+> fadeWindowsEventHook
                           <+> serverModeEventHook
                           <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                           <+> docksEventHook
                           <+> ewmhDesktopsEventHook
    , modMask            = myModMask
    , terminal           = myTerminal
    , startupHook        = myStartupHook
    , layoutHook         = myl 
    , workspaces         = withScreen 0 myWorkspaces ++ withScreen 1 myWorkspaces'
    , logHook            = fadeWindowsLogHook myFadeHook 
                           <+> workspaceHistoryHook 
                           <+> updatePointer (0.5, 0.5) (0.0, 0.0)
    , borderWidth        = myBorderWidth
    , normalBorderColor  = myNormColor
    , focusedBorderColor = myFocusColor
    , focusFollowsMouse  = True
    } 

copiesPP :: PP -> X PP
copiesPP pp = do
    copies <- wsContainingCopies
    let copyss = map (drop 1 . dropWhile isDigit) copies
    let check ws | ws `elem` copyss = colorOrange ws 
                 | otherwise = colorYellow . wrap "^" "^" $ ws
    return pp { ppHidden = check }

main :: IO()
main = do
    nn <- countScreens
    let barTop = [statusBarPropTo ("_XMONAD_LOG_"++ show n) ("xmobar -x " ++ show n ++ " ~/.config/xmobar/xmobarrct" ++ show n) (copiesPP $ marshallPP (S n) $ constructXmobarConfig (S n)) | n <- [0..nn-1]]
    let barBot = [statusBarPropTo ("_XMONAD_LOG_SCREEN_"++ show n) ("xmobar -x " ++ show n ++ " ~/.config/xmobar/xmobarrcts" ++ show n) (pure $ xmobarWinConfig (S n)) | n <- [0..nn-1]]
    xmonad . docks . withSB (mconcat $ barTop ++ barBot) . ewmhFullscreen $ ewmh myConfig'

xmobarWindowLists :: ScreenId -> X (Maybe String)
xmobarWindowLists s = do
    winset <- gets windowset
    urgents <- readUrgents
    sort <- getSortByIndex
    let wksAll = W.workspaces winset
    let wksOn = filter ((/= W.currentTag winset) . W.tag) $  filter (not . null . W.integrate' . W.stack) $ sort $ workspacesOn s wksAll
    let tag = map W.tag wksOn
    -- let wins = map (W.integrate' . W.stack) wksOn
    let wins = map (\x -> (x, W.integrate' $ W.stack x)) wksOn

    let winFmt w | w `elem` urgents         = ppUrgentC
                 | otherwise                = ppFocusC

    let clickWinFmt w = clickableWindow w . winFmt w

    let gs = length $ concatMap snd wins
    let wss = length $ map fst wins
    let indices = [ show (n :: Int) | n <- [1..gs] ] 
    let logWins win = mapM getName win >>= \titles -> pure [ " " ++ clickWinFmt w (i ++ ": " ++ sanitize (show tit)) | w <- win | tit <- titles | i <- indices ]
    let logR i = fmap ((("  | " ++ cleanUp (W.tag (fst (wins !! i)))) ++ ) . concat) (logWins $ snd (wins !! i))
    fmap (Just . concat) $ traverse logR [0..wss-1]
  where
        ppFocusC   = xmobarBorder "Bottom" "#ffff00" 1 . xmobarColor "#ffff00" ""
        ppUrgentC  = xmobarColor "#ffff00" "#800000:3,1"
        ppUnfocusC = xmobarColor "#b0b040" ""
        sanitize t = xmobarRaw $ shorten 40 t
        cleanUp = drop 1 . dropWhile isDigit 

xmobarWinConfig :: ScreenId -> PP
xmobarWinConfig s = xmobarPP {
    ppOrder = \(ws:l:t:ex) -> ex
  , ppExtras = [xmobarWindowLists s] 
}
