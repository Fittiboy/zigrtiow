# [Ray Tracing in One Weekend](https://raytracing.github.io/)
But in Zig!

# Book 1
## 2. Output an Image
Translating the first bit of code from the book into Zig, we have created
our first image!  

![A simple color gradient](samples/pngs/first_image.png )  

## 4. Rays, a Simple Camera, and Background
After some more Stuff™ was written, there are now rays and colors and
viewports and cameras!  
It's a lot more impressive behind the scenes than the produced image
lets on!  

![A simple color gradient (blue to white)](samples/pngs/white_blue_gradient.png)  

## 5. Adding a Sphere
I'm now able to add spheres to my scene! Following the book, I was able to
produce a simple image of a red sphere on my gradient.  

![A red sphere on top of a color gradient](samples/pngs/first_red_sphere.png)  

### Bonus
Before moving on to the next chapter, I wanted to add some depth to the very
flat sphere, so I decided to darken it based on the distance to the camera.  

![A slightly shaded, red sphere on top of a color gradient](samples/pngs/red_sphere_darken_experiment.png)  

After that, I wanted to have some more color, so I tried turning the
collision normal into a color.  
First, I used the absolute value:  

![A blue sphere with green and purple edges](samples/pngs/sphere_normal_abs_color.png)  

Then I added (1, 1, 1) to the normal and divided it by 2:  

![A sphere with soft color transitions](samples/pngs/sphere_normal_shifted_color.png)  

I also tried just norming the vector again after shifting it, but I like
the previous one better than this:  

![A darker sphere with color transitions](samples/pngs/sphere_normal_shifted_normal_color.png)  

### Bonus Bonus
Couldn't resist and wanted to see if I could add a naive light source. I could.  

![A red sphere, lit softly from the top right](samples/pngs/red_lit_sphere.png)  
