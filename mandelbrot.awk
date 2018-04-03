#!/usr/bin/gawk -f

function MyTime() {
  # /proc/uptime has more precision than strftime()
  getline < "/proc/uptime"
  close("/proc/uptime")
  return($1)
}

function pixel(Zr, Zi, Im, Re, Iter,   a, b, n) {
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
    #pix = (y>=(YSize/2))?"▄":" "

    Line = ""                 # Clear line buffer
    ColUp = ColDn = 0         # Blank pixel color
    PrevColUp = PrevColDn = 0 # Blank previous color

    ZiUp = ImUp = MinIm + StepY * y 
    ZiDn = ImDn = MinIm + StepY * y + (StepY * 0.5) 

    for (x=0; x<XSize; x++) { # For each pixel on lines
      Zr = Re = MinRe + StepX * x

      ColUp = (pixel(Zr, ZiUp, ImUp, Re, Iter)%8)+40 # Upper pixel color
      ColDn = (pixel(Zr, ZiDn, ImDn, Re, Iter)%8)+30 # Lower pixel color

      # Are pixels different from last time
      if ( (PrevColUp != ColUp) || (PrevColDn != ColDn) ) {
        # Add new color information
        Line = Line "\033["ColUp";"ColDn"m"
        PrevColUp = ColUp
        PrevColDn = ColDn
      }
      # Add pixel to line buffer
      Line = Line pix
    }
    # Add line to screen buffer
    Screen = Screen Line "\033[0m\n"
  }
  # Print screen buffer
  printf("%s", Screen)
}

function profile(p) {
  # Set defaults for all profile
  pix       = "▄"
  Iter      = 32
  nrFrames  = 150
  MinIm = -2; MaxIm = 2
  MinRe = -2; MaxRe = 2

  switch(p) {
    case 1:
      nrFrames = 400
      MinIm = -2.000; MaxIm = 2.000
      MinRe = -3.450; MaxRe = 0.550
      break;

    case 2:
      nrFrames = 400
      MinIm = -2.900; MaxIm = 1.100
      MinRe = -2.057; MaxRe = 1.943
      break;

    case 3:
      nrFrames = 400
      Iter     = 64
      MinIm = -1.990; MaxIm = 2.010
      MinRe = -1.720; MaxRe = 2.280
      break;

    case 4:
      nrFrames = 400
      MinIm = -1.405; MaxIm = 2.595
      MinRe = -1.675; MaxRe = 2.325
      break;

    case 5:
      nrFrames  = 400
      MinIm = -2.000; MaxIm = 2.000
      MinRe = -3.781; MaxRe = 0.219
      break;
  }
}

BEGIN {
  # get width and height of console
  if ("COLUMNS" in ENVIRON) {
    Width = ENVIRON["COLUMNS"]
    Height = ENVIRON["LINES"]
  } else {
    Width = 80; Height = 24
  }

  # find best 2:1 aspect ratio
  if (Width > Height*2) {
    XSize = Height*2
    YSize = Height-2
  } else {
    XSize = Width
    YSize = Width/2-2
  }

  # select profile to show
  profile(profl?profl:1)

  # reset fps counters
  FPS = "0.00"
  FrameCnt = 0
  TimeStart = TimeThen = TimeNow = MyTime()

  # hide cursor
  printf("\033[?25l")

  # start drawing frames
  for (frame=1; frame<=nrFrames; frame++) {
    # show more detail every 100 frames
    if ( (frame % 100) == 0 ) Iter += 8

    # zoom in 1/100 every frame
    ZoomSpeed = (MaxIm-MinIm)/100
    MinIm += ZoomSpeed; MaxIm -= ZoomSpeed
    MinRe += ZoomSpeed; MaxRe -= ZoomSpeed

    StepX = (MaxRe-MinRe)/XSize
    StepY = (MaxIm-MinIm)/YSize

    # Draw FPS counter and new frame
    #printf("\033[Hsize:%dx%d frame:%d/%d iter:%d %s   zmspd:%.6f winsz:%.6f\033[K\n", XSize, YSize, frame, nrFrames, Iter, FPS, ZoomSpeed, MaxIm-MinIm)
    printf("\033[Hsize:%dx%d frame:%d/%d iter:%d %s\033[K\n", XSize, YSize, frame, nrFrames, Iter, FPS)
    drawFrame(XSize, YSize, StepX, StepY, MinIm, MinRe, Iter)

    # If certain time has passed, calculate new FPS
    FrameCnt++
    TimeNow = MyTime()
    if ( (TimeNow - TimeThen) > 1) {
      FPS = sprintf("now:%.2ffps avg:%.2ffps", FrameCnt/(TimeNow-TimeThen), frame/(TimeNow-TimeStart))
      TimeThen = TimeNow
      FrameCnt = 0
    }
  }

  # show cursor
  printf("\033[?25h")
}