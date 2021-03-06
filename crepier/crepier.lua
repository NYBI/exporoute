--#!/usr/bin/env icesl-vanilla
-- This file is a CAD model for the software IceSL.
-- One can download it at http://webloria.loria.fr/~slefebvr/icesl/
-- This model is part of a bigger outer project: https://github.com/NYBI/exporoute
-- License: CC BY-SA 3.0 FR for Nybi.cc

function big_loop(r, d, h, alpha)
  return
    intersection(
        difference(cylinder(r+d, h), cylinder(r-d, h)),
        union{
          translate(0, r+d, 0) * cube(2*(r+d), 2*(r+d),h),
          rotate(0, 0, 180 - alpha) * ocube(r+d,r+d,h)
        }
    )
end

function small_loop(r, d, h, alpha)
  return
    intersection{
        difference(cylinder(r+d, h), cylinder(r-d, h)),
        ocube(r+d, r+d, h),
        rotate(0, 0, -alpha) * ocube(r+d, r+d, h)
    }
end

function loop(r, alpha, height, delta, base_length)
  length = base_length + r*cos(alpha)+r*tan(alpha)*cos(90-alpha)
  return translate(-r, length, 0) * union{
    big_loop(r, delta, height, alpha),
    translate(0, 2*(-r*cos(alpha)-r*tan(alpha)*cos(90-alpha)), 0) * small_loop(r, delta, height, alpha),
    translate(0, -r*cos(alpha)-r*tan(alpha)*cos(90-alpha), 0) * 
      rotate(0, 0, -alpha) * 
      cube(2*r*tan(alpha), 2 * delta, height),
    translate(r - delta, -length, 0) * ocube(2*delta, length, height)
  }
end

if ui_scalar == nil then
    function ui_scalar(a, b, c, d)
        return b
    end
end
r = ui_scalar('rayon', 50, 0, 100)
alpha = ui_scalar('alpha', 45/2, 0, 45)
height = ui_scalar('depth', 6, 0 ,10)
delta = ui_scalar('delta', 6, 1, 10)
screw_diameter = ui_scalar('screw diameter', 2, 1, 8)
wood_height = ui_scalar('wood height', 10, 0 ,20)
nb_crepe = math.ceil(ui_scalar('#crepes', 7, 1, 10))
longest_crepe = ui_scalar('longest crepe', 70, 2, 200)
crepe_width = ui_scalar('width of crepe', 15, 2, 200)
tolerance = ui_scalar('tolerance', 0.1, 0.1, 2)

--base_length = ui_scalar('base length', 70, 0, 150)
base_length = (nb_crepe+2) * crepe_width

function trail()
  return union{
    loop(r, alpha, height, delta, base_length),
    translate(0, 0, height) * loop(r, alpha, wood_height - height, screw_diameter + 2*tolerance, base_length)
  }
end

function plate()
    path = trail()
    plate_width = 2 * r + longest_crepe
    plate_height  = longest_crepe/2 + base_length + 2*r
    return difference(
        translate(-r, plate_height/2, 0) * cube(plate_width, plate_height, wood_height),
        path)
end

function crepe(len)
    l = r-delta+2*tolerance
    w = crepe_width / 4
    sr = math.sqrt(r*r - w*w)-l
    oblong = translate(0, 0, -wood_height) * intersection{
            translate(l, 0, 0) * cylinder(r, wood_height - height),
            translate(-l, 0, 0) * cylinder(r, wood_height - height),
        }
    return union{
        cube(len, crepe_width, wood_height),
        translate(0, 0, -wood_height) * cylinder(screw_diameter, wood_height),
        intersection{
            oblong,
            union{
                translate(0, 0, -wood_height) * cube(len, crepe_width/2, wood_height),
                translate(0, w, -25) * cylinder(sr, 50),
                translate(0, -w, -25) * cylinder(sr, 50)
                }
        }
    }
end

-- le plateau
emit(plate())

-- for viewing
if false then
	for i = 1, nb_crepe, 1 do
		emit(translate(0, (2*i-1)*crepe_width/2, wood_height) * crepe(longest_crepe - i * (longest_crepe / (nb_crepe+3))), i)
	end
end

-- for cutting
if true then
	for i = 1, nb_crepe, 1 do
		emit(translate(0, (3*i)*crepe_width/2, wood_height) * crepe(longest_crepe / i), 0)
	end
end
-- Crepe dans le virage
--emit(translate(-r, base_length + 2 *r, wood_height) * rotate(0,0,90)*crepe(),2)
