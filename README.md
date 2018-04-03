
I got this idea from a passer-by (sorry, I forgot your nick!) on #awk on Freenode who was implementing his mandelbrot-set generator in awk.
When I saw his static, single screen implementation draw a picture of 320x200 characters in somewhat of half a minute, I though I'd improve upon it.

First I started off with a simple speed improvement. Instead of his 'tput|sh' forking process for each pixel drawn, I started using direct ANSI escape sequences. This had the impact that the single frame was now drawn in a fraction of a second instead of half a minute.
Next I doubled the pixel density of the original by using a UTF-8 HALF-BLOCK (▄) character and made it have a background and a foreground color. This made the picture a lot sharper with not too much of an overhead.
Then I wanted to animate it and zoom in. Ofcourse this should be somewhat flexibel, so I made a profile() function that can set different parameters with a single choice.
Last but not least I made the sizing somewhat more flexible, by auto-detecting the COLUMNS and LINES environment variables (they need to be exported to work) and to get some 2:1 aspect ratio as to not stretch it weirdly in either way. (i.e. when your terminal is 80x24)

There are some other minor improvements like buffering the output screen to reduce flickering, having a status bar with FPS in the top line and having a variable drawing distance.

Example usage:
Run a preset 'profile 1' animation
```./mandelbrot.awk -v profile=1```

Run preset profile 2 with 100 frames and an aspect ratio of 1:1 
```./mandelbrot.awk -v profile=2 -v nframes=100 -v ratio=1:1```

Draw a single frame with drawing distance of 256
```./mandelbrot.awk -v nframes=1 -v iter=256```

Here's a (static) picture of the result:
![Mandelbrot image](/mandelbrot.jpg)

And a link to a moving version: [Mandelbrot movie](https://www.youtube.com/watch?v=yvru2ZmiAxM)

