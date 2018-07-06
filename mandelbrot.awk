#!/usr/bin/awk -f

function MyTime() {
  # /proc/uptime has more precision than strftime()
  getline < "/proc/uptime"
  close("/proc/uptime")
  return($1)
}

function Pixel(Zr, Zi, Im, Re, Iter,   a, b, n) {
  for (n=0; n<Iter; n++) {
    a = Zr*Zr
    b = Zi*Zi
    if (a+b > 4.0) break
    Zi = 2*Zr*Zi+Im
    Zr = a-b+Re
  }
  return(n)
}

function drawFrame(XSize, YSize, StepX, StepY, MinIm, MinRe, Iter,    x, y, Line, ColUp, ColDn, PrevColUp, PrevColDn, ImUp, ImDn, Re, Zr, ZiUp, ZiDn) {
  Screen = ""                 # Clear screen buffer

  for (y=0; y<YSize; y++) {    # For each line
    #pix = (y>=(YSize/2)) ? "▀" : " "

    Line = ""                 # Clear line buffer
    ColUp = ColDn = 0         # Blank pixel color
    PrevColUp = PrevColDn = 0 # Blank previous color

    ZiUp = ImUp = MinIm + StepY * y 
    ZiDn = ImDn = MinIm + StepY * y + (StepY * 0.5) 

    for (x=0; x<XSize; x++) { # For each pixel on lines
      Zr = Re = MinRe + StepX * x

      if (nrcolors) {
        # custom colormap from 256 colors
        ColUp = (Pixel(Zr, ZiUp, ImUp, Re, Iter)%nrcolors)+1 # Upper pixel color
        ColDn = (Pixel(Zr, ZiDn, ImDn, Re, Iter)%nrcolors)+1 # Lower pixel color
      } else {
        # old 8 colors
        ColUp = (Pixel(Zr, ZiUp, ImUp, Re, Iter)%8)+30 # Upper pixel color
        ColDn = (Pixel(Zr, ZiDn, ImDn, Re, Iter)%8)+40 # Lower pixel color
      }

      # Are pixels different from last time
      if ( (PrevColUp != ColUp) || (PrevColDn != ColDn) ) {
        # Add new color information
        Line = nrcolors ? Line "\033[38;5;"colormap[ColUp]";48;5;"colormap[ColDn]"m" : Line "\033["ColUp";"ColDn"m"
        PrevColUp = ColUp
        PrevColDn = ColDn
      }
      # Add pixel to line buffer
      Line = Line pix
    }
    # Add line to screen buffer
    if (VSync) Screen = Screen Line "\033[0m\n"
    else printf("%s\033[0m\n", Line)
  }
  # Print screen buffer
  if (VSync) printf("%s", Screen)
}

function Profile(profile, pixel, iter, vsync, statusbar, nframes, ratio) {
  # Set defaults for all profile
  pix       = "▀"
  Iter      = nrcolors ? (nrcolors * 3) : 32
  nrFrames  = 150
  MinIm = -2; MaxIm = 2
  MinRe = -2; MaxRe = 2
  AspectWidth  = 4
  AspectHeight = 3
  VSync     = 1
  StatusBar = 1

  if (profile == 0) {
      Iter = nrcolors ? (nrcolors * 16) : 256
      nrFrames = 1
      VSync = 0
  }
  if (profile == 1) {
      nrFrames = 400
      MinIm = -2.000; MaxIm = 2.000
      MinRe = -3.450; MaxRe = 0.550
  }
  if (profile == 2) {
      nrFrames = 400
      MinIm = -2.900; MaxIm = 1.100
      MinRe = -2.057; MaxRe = 1.943
  }
  if (profile == 3) {
      nrFrames = 400
      Iter = nrcolors ? (nrcolors * 4) : 64
      MinIm = -1.990; MaxIm = 2.010
      MinRe = -1.720; MaxRe = 2.280
  }
  if (profile == 4) {
      nrFrames = 400
      MinIm = -1.405; MaxIm = 2.595
      MinRe = -1.675; MaxRe = 2.325
  }
  if (profile == 5) {
      nrFrames  = 400
      MinIm = -2.000; MaxIm = 2.000
      MinRe = -3.781; MaxRe = 0.219
  }
  if (profile == 6) {
      nrFrames  = 400
      AspectWidth  = 2
      AspectHeight = 1
      MinIm = -1.000; MaxIm = 1.000
      MinRe = -3.781; MaxRe = 0.219
  }

  if (pixel) pix = pixel
  if (iter) Iter = iter
  if (vsync) VSync = (vsync in negative)?0:1
  if (statusbar) StatusBar = (statusbar in negative)?0:1
  if (nframes) nrFrames  = nframes
  if (ratio && (split(ratio, AspectRatio, ":") == 2) ) {
    AspectWidth  = int(AspectRatio[1]+0) ? AspectRatio[1] : 1
    AspectHeight = int(AspectRatio[2]+0) ? AspectRatio[2] : 1
  }

  # find best aspect ratio
  if ((Width*AspectHeight) > (Height*(AspectWidth*2))) {
    XSize = Height*(AspectWidth*2)/AspectHeight
    YSize = Height-(StatusBar+1)
  } else {
    XSize = Width
    YSize = Width*AspectHeight/(AspectWidth*2)-(StatusBar+1)
  }

}

BEGIN {
  # for color codes, see: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  colorstr[1]="0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7"
  colorstr[2]="16 52 88 124 160 196 202 208 214 220 226 226 228 229 230 231 225 219 213 207 201 165 129 93 57 21 27 33 39 45 51 50 49 48 47 46 40 34 28 22"
  colorstr[3]="16,17,18,19,20,21, 57, 93, 129, 165, 201 200 199 198 197 196 160 124 88 52"
  colorstr[4]="16,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,231"
  colorstr[5]="16 52 88 124 160 196 166 136 106 76 46 41 36 31 26 21"
  colorstr[6]="16 17 18 19 20 21 57 93 129 165 201 200 199 198 197 196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 87 123 159 195 231"

  negative["off"] = 1
  negative["false"] = 1
  negative["no"] = 1

  # get width and height of console
  if ("COLUMNS" in ENVIRON) {
    Width = ENVIRON["COLUMNS"]
    Height = ENVIRON["LINES"]
  } else {
    "tput cols"  | getline Width
    "tput lines" | getline Height
  }
  if ( !(Width && Height) ) { Width = 80; Height = 24 }

  # Set colormap (-v cmap=<value>)
  if (cmap in colorstr)
    nrcolors = split(colorstr[cmap], colormap, /[, ]+/)

  # select profile to show
  Profile(profile?profile:0, pixel, iter, vsync, statusbar, nframes, ratio)

  # reset fps counters
  FPS = "0.00"
  FrameCnt = 0
  TimeStart = TimeThen = TimeNow = MyTime()
  StartWidth = MaxIm-MinIm
  StartHeight = MaxRe-MinRe

  # hide cursor
  printf("\033[?25l")

  # start drawing frames
  for (frame=1; frame<=nrFrames; frame++) {
    # show more detail every 100 frames
    if ( (frame % 100) == 0 ) Iter += nrcolors ? nrcolors : 8

    # zoom in 1/100 every frame
    ZoomSpeedX = (MaxIm-MinIm)/100
    ZoomSpeedY = (MaxRe-MinRe)/100
    MinIm += ZoomSpeedX; MaxIm -= ZoomSpeedX
    MinRe += ZoomSpeedY; MaxRe -= ZoomSpeedY

    ZoomFactorX = sprintf("%.1f", StartWidth/(MaxIm-MinIm))
    ZoomFactorY = sprintf("%.1f", StartHeight/(MaxRe-MinRe))

    StepX = (MaxRe-MinRe)/XSize
    StepY = (MaxIm-MinIm)/YSize

    # Draw status bar and new frame
    printf("\033[H")
    if (StatusBar) printf("size:%dx%d frame:%d/%d iter:%d zoom:%sx %s\033[K\n", XSize, YSize*2, frame, nrFrames, Iter, ZoomFactorX, FPS)

    drawFrame(XSize, YSize, StepX, StepY, MinIm, MinRe, Iter)

    # If certain time has passed, calculate new FPS
    if (StatusBar) {
      FrameCnt++
      TimeNow = MyTime()
      if ( (TimeNow - TimeThen) > 1) {
        FPS = sprintf("now:%.2ffps avg:%.2ffps", FrameCnt/(TimeNow-TimeThen), frame/(TimeNow-TimeStart))
        TimeThen = TimeNow
        FrameCnt = 0
      }
    }
  }

  # show cursor
  printf("\033[?25h")
}
