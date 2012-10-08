require 'spec_helper'

describe Dradis::Node do
  before(:each) do
    @node = Dradis::Node.new
  end

  it "shouldn't be valid without a label" do
    @node.should_not be_valid
    @node.should have(1).error_on(:label)
    @node.errors[:label].first.should == "can't be blank"
    @node.label = 'rspec node'
    @node.should be_valid
  end

  it "should delete all nested nodes when deleted" do
    parent = FactoryGirl.create(:node)

    3.times do
      parent.children << FactoryGirl.create(:node)
    end

    child_ids = parent.children.map(&:id)

    parent.destroy

    child_ids.each do |id|
      lambda{ Dradis::Node.find(id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "should delete all associated notes when deleted" do
    node = FactoryGirl.create(:node)

    3.times do
      node.notes << FactoryGirl.create(:note)
    end

    note_ids = node.notes.map(&:id)

    node.destroy

    note_ids.each do |id|
      lambda{ Dradis::Note.find(id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  pending "should delete all associated attachments"
  # it "should delete all associated attachments" do
  #   node = FactoryGirl.create(:node)
  # 
  #   attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png'), :node_id => node.id )
  #   attachment.save
  # 
  #   node.destroy
  # 
  #   File.exists?(attachment.fullpath).should be_false
  # end

  pending "should delete it's corresponding attachment subfolder when deleted"
  # it "should delete it's corresponding attachment subfolder when deleted" do
  #   node = FactoryGirl.create(:node)
  # 
  #   attachment = Attachment.new( Rails.root.join('public', 'images', 'rails.png'), :node_id => node.id )
  #   attachment.save
  # 
  #   node.destroy
  # 
  #   File.exists?(Attachment.pwd.join(node.id.to_s)).should be_false
  # end

  it "should assign a default 0 position if none is provided" do
    node = FactoryGirl.create(:node)
    node.should respond_to(:position)
    node.should respond_to(:position=)
    node.position.should eq(0)
  end

  it "should keep the position when provided" do
    node = FactoryGirl.create(:node)
    node.position = 3
    node.save.should eq(true)
    node = Dradis::Node.last
    node.position.should eq(3)
  end
end
