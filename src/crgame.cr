require "cray"

require "./util"
require "./structs"
require "./entity"
require "./entities"

class EntityManager
    property entities = [] of Entity
    @player : Player?

    def player
        if @player.nil?
            @player = @entities.find(&.is_a? Player).as(Player)
        end

        @player.as(Player)
    end

    def update (time_delta)
        @entities.each do |v|
            v.update time_delta
        end

        dynamic_entities = @entities.select &.dynamic
        static_entities = @entities.select &.static

        collisions = [] of {Entity, Entity}
        dynamic_entities.each do |entity|

            @entities.each do |other_entity|
                next if entity == other_entity

                collisions << {entity, other_entity} if entity.collides_with? other_entity
            end
        end

        collisions.each do |entity_a, entity_b|
            entity_a.handle_collision_with entity_b
            entity_b.handle_collision_with entity_a
        end

    end
end

player = Player.new

entity_manager = EntityManager.new
entity_manager.entities << player
entity_manager.entities << Floor.new
entity_manager.entities += (0..300).map do
    cube = Cube.new
    cube.height = rand(2..10)
    cube.position = Vector3.new(rand(-50..50), cube.height / 2.0, rand(-50..50))
    cube.color = choose(LibRay::BLUE, LibRay::RED, LibRay::GREEN)
    cube
end

LibRay.set_config_flags LibRay::FLAG_WINDOW_RESIZABLE | LibRay::FLAG_MSAA_4X_HINT | LibRay::FLAG_VSYNC_HINT
LibRay.init_window 800, 450, "Example: hello_world"

LibRay.set_target_fps 60

while !LibRay.window_should_close?
    time_delta = LibRay.get_frame_time

    movement = Vector3.new
    movement += Vector3.right if any_key_down?(LibRay::KEY_RIGHT, LibRay::KEY_D)
    movement += Vector3.left if any_key_down?(LibRay::KEY_LEFT, LibRay::KEY_A)
    movement += Vector3.forward if any_key_down?(LibRay::KEY_UP, LibRay::KEY_W)
    movement += Vector3.backward if any_key_down?(LibRay::KEY_DOWN, LibRay::KEY_S)
    movement += Vector3.backward if any_key_down?(LibRay::KEY_DOWN, LibRay::KEY_S)
    movement += Vector3.upward if any_key_pressed?(LibRay::KEY_SPACE)
    player.movement = movement

    entity_manager.update time_delta

    LibRay.begin_drawing
    LibRay.clear_background LibRay::WHITE
    LibRay.begin_3d_mode player.camera.to_c

    draw_cube(player.position, player.bounding_box, LibRay::DARKGREEN)

    cubes = entity_manager.entities.select(&.is_a? Cube).map(&.as(Cube))
    cubes.each do |cube|
        draw_cube(cube.position, cube.bounding_box, cube.color)
    end

    LibRay.draw_grid 100, 1

    LibRay.end_3d_mode

    LibRay.draw_fps 10, 10
    LibRay.draw_text "velocity: #{player.velocity.to_s}", 10, 30, 12, LibRay::BLACK
    LibRay.draw_text "position: #{player.position.to_s}", 10, 50, 12, LibRay::BLACK

    LibRay.end_drawing
end

LibRay.close_window
