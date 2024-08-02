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

Before moving on, I wanted to add some depth to the very flat sphere,
so I decided to darken it based on the distance to the camera!  

![A slightly shaded, red sphere on top of a color gradient](samples/pngs/red_sphere_darken_experiment.png)  
