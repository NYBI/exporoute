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

r = ui_scalar('rayon', 60, 0, 100)
alpha = ui_scalar('alpha', 45/2, 0, 45)
height = ui_scalar('depth', 6, 0 ,10)
delta = ui_scalar('delta', 6, 1, 10)
base_length = ui_scalar('base length', 70, 0, 150)
screw_radius = ui_scalar('screw radius', 2, 1, 8)
wood_height = ui_scalar('wood height', 10.15, 0 ,20)
longest_crepe = ui_scalar('longest crepe', 100, 2, 200)

function trail()
  return union{
    loop(r, alpha, height, delta, base_length),
    translate(0, 0, height) * loop(r, alpha, wood_height - height, screw_radius/2 + 0.5, base_length)
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

-- le plateau
emit(plate())

-- la plus grande crepe
emit(translate(0, 0, wood_height) * cube(longest_crepe, 10, wood_height),2)

-- Crepe dans le virage
emit(translate(-r, base_length + 2 *r, wood_height) * rotate(0,0,90)*cube(longest_crepe, 10, wood_height),2)