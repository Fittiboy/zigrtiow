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

## 6. Surface Normals and Multiple Objects
Turns out chapter 6 wanted me to do what I already did at the end of
chapter 5 on my own!  

Later, a list of renderable objects was introduced, allowing me to have
multiple objects in the image at the same time!  

![A small sphere hovering over a large sphere](samples/pngs/multiple_spheres.png)  

Before I did that, I actually made two red spheres using my simple light
source.  

![A small and a large sphere, softly lit from above](samples/pngs/two_shaded_red_spheres.png)  

## 8. Antialiasing
Chapter 7 was about doing some refactoring which didn't apply to my
implementation, as the camera was already in its own file, just under a
different name.  
In chapter 8, however, I added something cool: Antialiasing! Through
random sampling of a small square around each target pixel, and
subsequent averaging of the sampled values, a less jagged edge is
produced, which looks a lot nicer.  
Look at the direct comparison!  

![A small sphere hovering over a large sphere](samples/pngs/multiple_spheres.png)
![A small sphere hovering over a large sphere, after antialiasing](samples/pngs/first_aa.png)  

## 9. Diffuse Materials
At the beginning of this chapter, a couple of randomization methods are
implemented, which are then used to enable diffuse materials.  
Here is a first example, using the two spheres from before.  

![Two gray spheres](samples/pngs/first_diffuse.png)  

It turns out the image is a lot darker than it should be, due to a
phenomenon called "shadow acne."  
The point at which a ray intersects a sphere is never return perfectly,
due to floating point errors. If the returned value is ever so slightly
below the sphere's surface, casting another ray from that point will lead
to another intersection immediately.  
This problem is solved by simply ignoring any collisions for some very
small values of `t`.  
Here is the result of that fix.  

![Two gray sphere, lighter and smoother than before](samples/pngs/fix_acne.png)  

After implementing this simple uniform reflection, it was replaced with
more realistic lambertian reflection instead, which resulted in this
image.  

![Two gray spheres, lightly shaded](samples/pngs/first_lambertian.png)  

Setting the reflectance to 10%, 30%, 50%, 70%, and finally 90% shows the
gamut of the renderer.  

![Five versions of the spheres overlaid, at different brightness levels](samples/pngs/original_gamut.png)  

Here is the gamut after applying gamma correction, showing the brightness
more correctly.  

![Gamma corrected image of the spheres at different brightness levels](samples/pngs/corrected_gamut.png)  

## 10. Metal
After lots of refactoring, there are now different materials.  
In addition to the original lambertian diffuse reflector, there is now
also metal!  

![Two shiny metals spheres flanking a blue sphere on top of a yellow-ish sphere](samples/pngs/materials.png)  

At the end of the chapter, fuzzy reflections were introduced, enabling
spheres to look like this.  

![Two fuzzy, shiny metal spheres flanking a blue sphere on top of a yellow-ish sphere](samples/pngs/fuzzy_reflection.png)  

## 11. Dielectrics
This chapter introduced dielectrics, which can refract light, instead of
reflecting it.  
The first refractive material introduced is glass.  

![A glass sphere, a blue sphere, and a shiny metal sphere on top of a yellow-ish sphere](samples/pngs/first_glass.png)  

Before moving on in the book, I decided to try to place a second sphere
inside the glass sphere, with the inverse of the glass' refractive index,
to see what that would look like.  

![A hollow glass sphere, a blue sphere, and a shiny metal sphere on top of a yellow-ish sphere](samples/pngs/experimental_hollow_glass.png)  

The Way the book tested the partial reflection of rays at shallow angles
was to model the sphere as an air bubble in water.  

![An air bubble in water, a blue sphere, and a shiny metal sphere on top of a yellow-ish sphere](samples/pngs/air_bubble.png)  

After introducing Schlick's approximation for reflectance, the book uses
a hollow glass sphere to show this, which is exactly what I did myself
two picture above from here, except now with reflectance.  

![A hollow glass sphere, a blue sphere, and a shiny metal sphere on top of a yellow-ish sphere](samples/pngs/schlick_approx.png)  

## 12. Positionable Camera
The next step in making the camera customizable is to change the field
of view.  

![A large blue sphere and a large red sphere next to each other](samples/pngs/fov.png)  

After making implementing arbitrary camera positions (and fixing a sign
error), I was able to move the camera to wherever I want.  

![The three-sphere scene from above and to the right, slightly rotated](samples/pngs/own_angle.png)  

In the book itself, two other angles were used as examples.  

![Three-sphere scene from above and afar](samples/pngs/custom_angle_1.png)
![Three-sphere scene from above and close up](samples/pngs/custom_angle_2.png)  

Experimenting a bit, I think this is my favorite angle.  

![Three-sphere scene from slightly below and close-up](samples/pngs/coolest_angle.png)  

## 13. Defocus Blur
One final feature the book introduces is defocus blur, which emits rays
not from the center of the camera, but from a small disk around the
center instead.  
Resulting images have a nice blur.  

![Three spheres, two of which are out of focus](samples/pngs/defocus_blur.png)  

## 14. Where Next?
Before the book is over, there was one last render, which took about 12
minutes on my system.  

![A collection of spheres](samples/pngs/final_render.png)  

But it wouldn't be a true final render if it was actually final.  
So there's an even more final render, with all three of the big spheres
made of glass!  

![A collection of spheres, with three large glass spheres](samples/pngs/final_all_glass.png)  
