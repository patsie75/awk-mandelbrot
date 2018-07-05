
I got this idea from a passer-by (sorry, I forgot your nick!) on #awk on Freenode who was implementing his mandelbrot-set generator in awk.  
When I saw his static, single screen implementation draw a picture of 320x200 characters in somewhat of half a minute, I though I'd improve upon it.

First I started off with a simple speed improvement. Instead of his 'tput|sh' forking process for each pixel drawn, I started using direct ANSI escape sequences. This had the impact that the single frame was now drawn in a fraction of a second instead of half a minute.  
Next I doubled the pixel density of the original by using a UTF-8 HALF-BLOCK (▄) character and made it have a background and a foreground color. This made the picture a lot sharper with not too much of an overhead.  
Then I wanted to animate it and zoom in. Ofcourse this should be somewhat flexibel, so I made a profile() function that can set different parameters with a single choice.  
Last but not least I made the sizing somewhat more flexible, by auto-detecting the COLUMNS and LINES environment variables (they need to be exported to work) and to get some 2:1 aspect ratio as to not stretch it weirdly in either way. (i.e. when your terminal is 80x24)

There are some other minor improvements like buffering the output screen to reduce flickering, having a status bar with FPS in the top line and having a variable drawing distance.

A recently added feature is having a configurable colormap with choice from 256-colors. There are currently five colormaps to choose from (of which the first is just the old 8-color)  
You can choose them with the option `-v cmap=<#>`.  
If you want to add your own colormap, you can find the color/number overview here: https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit  
Just add a `colorstr[#]="1 2 3 4 5"` style string in the `BEGIN` section of the script. Or better yet, add it and make me a pull-request so others can enjoy your work :)


Example usage:  
Not all environments export the `COLUMNS` and `LINES` variables, so you may want to start off with:  
`export COLUMNS LINES`

Run a preset 'profile 1' animation  
`./mandelbrot.awk -v profile=1`

Run a preset 'profile 2' animation with custom colormap #2
`./mandelbrot.awk -v profile=2 -v cmap=2`

Run preset profile 3 with 100 frames and an aspect ratio of 1:1  
`./mandelbrot.awk -v profile=3 -v nframes=100 -v ratio=1:1`

Draw a single frame with drawing distance of 256 without status bar and draw line-by-line  
`./mandelbrot.awk -v nframes=1 -v iter=256 -v statusbar=off -v vsync=off`

Here's a (static) picture of the result:
![Mandelbrot image](/mandelbrot.png)

And a link to a moving version: [Mandelbrot movie](https://www.youtube.com/watch?v=yvru2ZmiAxM)

