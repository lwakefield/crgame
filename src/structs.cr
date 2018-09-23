require "cray"

private macro swap(x, y)
    {{x}}, {{y}} = {{y}}, {{x}}
end

struct BoundingBox
    getter min : Vector3
    getter max : Vector3
    def initialize(min, max)
        min_x, max_x = min.x, max.x
        min_y, max_y = min.y, max.y
        min_z, max_z = min.z, max.z

        swap(min_x, max_x) if min_x > max_x
        swap(min_y, max_y) if min_y > max_y
        swap(min_z, max_z) if min_z > max_z

        @min = Vector3.new(min_x, min_y, min_z)
        @max = Vector3.new(max_x, max_y, max_z)
    end

    def + (vector)
        BoundingBox.new(@min + vector, @max + vector)
    end

    def collides_with? (bounding_box)
        LibRay.check_collision_boxes(to_c, bounding_box.to_c)
    end

    def to_c
        LibRay::BoundingBox.new(min: @min.to_c, max: @max.to_c)
    end
end

struct Vector3
    getter x, y, z : Float64

    def initialize(@x = 0.0, @y = 0.0, @z = 0.0)
    end

    def initialize(x : Number, y : Number, z : Number)
        @x = x.to_f64
        @y = y.to_f64
        @z = z.to_f64
    end

    def + (other = nil)
        return self if other.nil?

        Vector3.new(@x + other.x, @y + other.y, @z + other.z)
    end

    def - (other = nil)
        return Vector3.new(-@x, -@y, -@z) if other.nil?

        Vector3.new(@x - other.x, @y - other.y, @z - other.z)
    end

    def * (scalar)
        Vector3.new(scalar * @x, scalar * @y, scalar * @z)
    end

    def / (scalar)
        Vector3.new(@x / scalar, @y / scalar, @z / scalar)
    end

    def normal
        return self if self == Vector3.zero
        self / magnitude
    end

    def magnitude
        (@x ** 2 + @y ** 2 + @z ** 2) ** 0.5
    end

    def to_c
        LibRay::Vector3.new(x: @x, y: @y, z: @z)
    end

    def to_s(precision=2)
        sprintf("Vector3(@x=%.2f, @y=%.2f, @z=%.2f)", @x, @y, @z)
    end
end

struct Number
    def * (vector)
        vector * self
    end

    def / (vector)
        vector * self
    end
end

struct Vector3
    class_getter right    = Vector3.new(0, 0, 1)
    class_getter left     = Vector3.new(0, 0, -1)
    class_getter forward  = Vector3.new(1, 0, 0)
    class_getter backward = Vector3.new(-1, 0, 0)
    class_getter upward   = Vector3.new(0, 1, 0)
    class_getter downward = Vector3.new(0, -1, 0)
    class_getter zero     = Vector3.new(0, 0, 0)
    class_getter one      = Vector3.new(1, 1, 1)
end

struct Camera3D
    property position : Vector3
    property target : Vector3

    def initialize ()
        @base = LibRay::Camera.new
        @base.up = Vector3.new(0, 1, 0).to_c
        @base.fovy = 60.0
        @base.type = LibRay::CameraType::CAMERA_PERSPECTIVE
        @position = Vector3.new
        @target = Vector3.new
    end

    def to_c
        @base.position = @position.to_c
        @base.target = @target.to_c
        @base
    end
end
