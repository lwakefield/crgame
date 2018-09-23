require "./spec_helper"

require "../src/structs.cr"

describe BoundingBox do
    it "collides_with? works" do
        box1 = BoundingBox.new(Vector3.zero, Vector3.one)
        box2 = BoundingBox.new(Vector3.zero, Vector3.one)
        box1.collides_with?(box2).should eq true

        box3 = BoundingBox.new(Vector3.one, 2 * Vector3.one)
        box1.collides_with?(box3).should eq true

        box4 = BoundingBox.new(2 * Vector3.one, 3 * Vector3.one)
        box1.collides_with?(box4).should eq false

        # box1 = BoundingBox.new(
        #     Vector3.new(6.500084519377641, -0.5, -1.5),
        #     Vector3.new(7.500084519377641, 0.5, 1.5))
        # box2 = BoundingBox.new(
        #     Vector3.new(-17.0, -35.0, 0.0),
        #     Vector3.new(-15.0, -33.0, 2.0)
        # )

    end
end

describe Vector3 do
    it "does math correctly" do
        (Vector3.new(1, 1, 1) * 1.5).should eq Vector3.new(1.5, 1.5, 1.5)
        (1.5 * Vector3.new(1, 1, 1)).should eq Vector3.new(1.5, 1.5, 1.5)

        (1.5 * Vector3.new(-1, -1, -1)).should eq Vector3.new(-1.5, -1.5, -1.5)

        (-Vector3.one).should eq Vector3.new(-1, -1, -1)
    end
end
