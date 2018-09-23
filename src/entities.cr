require "math"

require "./entity"
require "./structs"

GRAVITY = 50

class Player < Entity
    getter   camera   : Camera3D
    property movement : Vector3

    class_getter max_ground_speed = 15
    class_getter acceleration     = 100
    class_getter jump_velocity    = 20

    def initialize
        @movement = Vector3.zero
        @camera = Camera3D.new
        @width, @depth, @height = 1, 1, 3
        @position = Vector3.new(0, 3, 0)

        self.dynamic = true
    end

    def update (time_delta)
        if @movement.y > 0 && @jumping != true
            @velocity += Vector3.upward * @@jump_velocity
            @jumping = true
        end

        # we _always_ simulate gravity
        @velocity += Vector3.downward * GRAVITY * time_delta

        unless @jumping
            ground_movement = Vector3.new(@movement.x, 0, @movement.z)
            ground_velocity = Vector3.new(@velocity.x, 0, @velocity.z)
            target_velocity = ground_movement.normal * @@max_ground_speed

            is_accelerating? = ground_movement != Vector3.zero && ground_velocity != target_velocity
            is_decelrating? = ground_movement == Vector3.zero && ground_velocity != Vector3.zero

            diff_vector = (target_velocity - ground_velocity)
            time_normalized_diff_vector = diff_vector.normal * time_delta * @@acceleration
            @velocity += diff_vector.magnitude < time_normalized_diff_vector.magnitude ? diff_vector : time_normalized_diff_vector
        end

        @position += (@velocity * time_delta.to_f64)

        update_camera_position
    end

    def update_camera_position
        offset = Vector3.new(-10, 10, 0)
        @camera.position = @position + offset
        @camera.target = @position
    end

    def handle_collision_with (other_entity)
        this_box = (bounding_box + @position)
        other_box = (other_entity.bounding_box + other_entity.position)

        diff_1 = this_box.max - other_box.min
        diff_2 = other_box.max - this_box.min

        # We make the assumption that the smallest diff is where the collision
        # needs adjustment
        adjustment = [
            {diff_1.x, Vector3.backward},
            {diff_2.x, Vector3.forward},
            {diff_1.y, Vector3.downward},
            {diff_2.y, Vector3.upward},
            {diff_1.z, Vector3.left},
            {diff_2.z, Vector3.right},
        ].sort { |a, b| a[0] <=> b[0] }.first
        scalar, vector = adjustment[0], adjustment[1]

        @position += scalar * vector

        if [Vector3.upward, Vector3.downward].includes? vector
            @velocity = Vector3.new(@velocity.x, 0, @velocity.z)
            # TODO: I think this may need to be adjusted when hitting a roof
            @jumping = false
        elsif [Vector3.forward, Vector3.backward].includes? vector
            @velocity = Vector3.new(0, @velocity.y, @velocity.z)
        elsif [Vector3.left, Vector3.right].includes? vector
            @velocity = Vector3.new(@velocity.x, @velocity.y, 0)
        end

        update_camera_position
    end
end

class Cube < Entity
    property position
    property color = LibRay::Color.new
    property height

    def initialize
        @width, @depth, @height = 2, 2, 2
    end
end

class Floor < Entity
    getter position : Vector3 = Vector3.zero
    getter width = 100
    getter depth = 100
end
