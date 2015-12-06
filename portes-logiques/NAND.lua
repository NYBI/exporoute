h = 3
shapes = svg(Path .. 'activite-machine.svg', 90)
for i,contour in ipairs(shapes) do
   shapes[i] = linear_extrude_from_oriented(v(0, 0, 3),contour)
--  emit(shapes[i], h)
end

small_gear = difference(shapes[1], shapes[2])
emit(small_gear, 2)
big_gear = difference(shapes[4], shapes[5])
emit(big_gear, 2)
input_1 = shapes[6]
emit(input_1, 1)
input_2 = translate(0, 180, h) * rotate(180, 0, 0) * input_1
emit(input_2, 1)
output_3 = translate(185, 0, h) * rotate(0, 180, 0) * input_1
emit(output_3, 1)

arm = union(translate(0,0,h) * difference(shapes[12], shapes[13]), shapes[8])
emit(arm, 4)

others = {9, 14, 15, 16, 17, 18, 19}
for _, i in ipairs(others) do
   emit(shapes[i])
end
others = {10, 11, 20, 21}
for _, i in ipairs(others) do
   emit(translate(0, 0, h) * shapes[i])
end
emit(translate(90, 90, -h) * box(180, 180, h))
