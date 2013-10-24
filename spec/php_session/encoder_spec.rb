require 'spec_helper'

describe PHPSession::Encoder do
  describe ".encode" do
    context "when given string value" do
      it "should return 'KEY|SERIALIZED_STRING'" do
        expect(
          PHPSession::Encoder.encode({:hoge => "nyan"})
        ).to eq('hoge|s:4:"nyan";')
      end
    end
    context "when given multi string value" do
      it "should return 'KEY|SERIALIZED_STRING'" do
        expect(
          PHPSession::Encoder.encode({:hoge => "テスト"})
        ).to eq('hoge|s:9:"テスト";')
      end
    end
    context "when given int value" do
      it "should return 'KEY|SERIALIZED_INT" do
        expect(
          PHPSession::Encoder.encode({:hoge => 1})
        ).to eq ('hoge|i:1;')
      end
    end
    context "when given double value" do
      it "should return 'KEY|DOUBLE|'" do
        expect(
          PHPSession::Encoder.encode({:hoge => 1.1})
        ).to eq('hoge|d:1.1;')
      end
    end
    context "when given nil value" do
      it "should return 'KEY|N;'" do
        expect(
          PHPSession::Encoder.encode({:hoge => nil})
        ).to eq('hoge|N;')
      end
    end
    context "when given boolean value" do
      it "should return 'KEY|b:(0|1);'" do
        expect(
          PHPSession::Encoder.encode({:hoge => true})
        ).to eq('hoge|b:1;')
        expect(
          PHPSession::Encoder.encode({:hoge => false})
        ).to eq('hoge|b:0;')
      end
    end
    context "when given hash value" do
      it "should return 'KEY|a:SIZE:ARRAY'" do
        expect(
          PHPSession::Encoder.encode({:hoge => {:a => 1,:b => 2,:c => 3}})
        ).to eq('hoge|a:3:{s:1:"a";i:1;s:1:"b";i:2;s:1:"c";i:3;}')
      end
    end
    context "when given array value" do
      it "should return 'KEY|a:SIZE:ARRAY'" do
        expect(
          PHPSession::Encoder.encode({:hoge => [1, 2, 3]})
        ).to eq('hoge|a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}')
      end
    end
    context "when given Struct" do
      it "should return 'KEY|o:CLASSNAME_SIZE:PROPERTIES_SIZE:{PROPERTIES_AND_VALUES}'" do
        piyo = Struct.const_defined?(:Test) ? Struct.const_get(:Test) : Struct.new("Test", :p1, :p2)
        expect(
          PHPSession::Encoder.encode(:hoge => piyo.new(1, 2))
        ).to eq('hoge|o:4:"Test":2:{s:2:"p1";i:1;s:2:"p2";i:2;}')
      end
    end
    context "when given nested value" do
      it "should return nested serialized string" do
        hash = {
          :key => {
            :hoge => {
              :fuga => "nyan"
            }
          }
        }
        expect(
          PHPSession::Encoder.encode(hash)
        ).to eq('key|a:1:{s:4:"hoge";a:1:{s:4:"fuga";s:4:"nyan";}}')
      end
    end
  end
end
