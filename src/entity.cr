require "./structs.cr"

abstract class Entity
    getter dynamic = false
    getter static = false

    getter velocity : Vector3 = Vector3.zero
    getter position : Vector3 = Vector3.zero
    getter width = 0
    getter height = 0
    getter depth = 0

    def dynamic= (@dynamic)
        @static = !@dynamic
    end

    def static= (@static)
        @dynamic = !@dynamic
    end

    def dynamic? (@dynamic)
        @dynamic
    end

    def static?
        @static
    end

    def bounding_box
        BoundingBox.new(
            Vector3.new(-@depth / 2.0, -@height / 2.0, -@width / 2.0),
            Vector3.new(@depth / 2.0, @height / 2.0, @width / 2.0),
        )
    end

    def collides_with? (other)
        (bounding_box + position).collides_with? (other.bounding_box + other.position)
    end

    def update (time_delta)
    end

    def handle_collision_with (other_entity : Entity)
    end
end
