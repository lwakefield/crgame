require "cray"

def choose (*choices)
    choices[(rand(0...choices.size))]
end

def any_key_down? (*keys)
    keys.any? { |k| LibRay.key_down? k }
end

def any_key_pressed? (*keys)
    keys.any? { |k| LibRay.key_pressed? k }
end

def draw_cube (position : Vector3, bounding_box : BoundingBox, color : LibRay::Color)
    depth = (bounding_box.min.x - bounding_box.max.x)
    height = (bounding_box.min.y - bounding_box.max.y)
    width = (bounding_box.min.z - bounding_box.max.z)

    LibRay.draw_cube(position.to_c,       width, height, depth, color)
    LibRay.draw_cube_wires(position.to_c, width, height, depth, LibRay::BLACK)
end
