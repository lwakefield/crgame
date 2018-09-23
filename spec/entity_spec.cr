require "./spec_helper"

require "../src/util"
require "../src/entity"

class Cube < Entity
    def initialize (@position = Vector3.zero)
        @width, @depth, @height = 1, 1, 1
    end

    def update (time_delta) end
end

describe Entity do
    it "collides_with? works" do
        cube1, cube2 = Cube.new, Cube.new(Vector3.new(0.25, 0.25, 0.25))
        cube1.collides_with?(cube2).should eq true
    end
end

