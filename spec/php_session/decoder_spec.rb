require 'spec_helper'

describe PHPSession::Decoder do
  describe ".decode" do
    context "when given invalid session format" do
      it "should raise ParseError" do
        expect {
          PHPSession::Decoder.decode("invalid format string")
        }.to raise_error(PHPSession::Errors::ParseError)
      end
    end
    context "when given a String value in session data" do
      it "should return a hash which has a string" do
        expect(
          PHPSession::Decoder.decode('key|s:3:"str";')
        ).to eq({"key" => "str"})
      end
    end
    context "when given a multibyte string in session data" do
      it "should return a hash which has a multibyte string" do
        expect(
          PHPSession::Decoder.decode('key|s:9:"テスト";')
        ).to eq({"key" => "テスト"})
      end
    end
    context "when given a Integer value in session data" do
      it "should return a hash which has a int value" do
        expect(
          PHPSession::Decoder.decode('key|i:10;')
        ).to eq({"key" => 10})
      end
    end
    context "when given a doulble value in session data" do
      it "should return a hash which has a float value" do
        expect(
          PHPSession::Decoder.decode('key|d:3.1415;')
        ).to eq({"key" => 3.1415})
      end
    end
    context "when given a null in session data" do
      it "should return a hash which has a nil" do
        expect(
          PHPSession::Decoder.decode('key|N;')
        ).to eq({"key" => nil})
      end
    end
    context "when given boolean in session data" do
      it "should return a  hash which has a boolean" do
        expect(
          PHPSession::Decoder.decode('key|b:1;')
        ).to eq({"key" => true})
        expect(
          PHPSession::Decoder.decode('key|b:0;')
        ).to eq({"key" => false})
      end
    end
    context "when given a empty array in session data" do
      it "should return a hash which contains no data" do
        expect(
          PHPSession::Decoder.decode('key|a:0:{}')
        ).to eq({"key" => {}})
      end
    end
    context "when given a AssociatedArray value in session data" do
      it "should return a hash which has a hash" do
        expect(
          PHPSession::Decoder.decode('key|a:2:{s:2:"k1";s:2:"v1";s:2:"k2";s:2:"v2";}')
        ).to eq({
          "key" => {
            "k1" => "v1",
            "k2" => "v2"
          }
        })
      end
    end
    context "when given a object" do
      it "should return a hash which has a object" do
        data = PHPSession::Decoder.decode('key|O:4:"Nyan":1:{s:1:"k";s:1:"v";}')
        expect(data["key"].class).to eq(Struct::Nyan)
        expect(data["key"].k).to eq("v")
      end
    end
    context "when given a object which has no property" do
      it "should return a hash which has a object" do
        data = PHPSession::Decoder.decode('key|O:4:"Piyo":0:{}')
        expect(data["key"].class).to eq(Struct::Piyo)
      end
    end
    context "when given objects which have same class" do
      it "should return same class Structs" do
        data = PHPSession::Decoder.decode('key|a:2:{s:1:"1";O:4:"Nyan":1:{s:1:"k";s:1:"v";}s:1:"2";O:4:"Nyan":1:{s:1:"k";s:1:"v";}}')
        expect(data["key"]["1"].class).to eq(Struct::Nyan)
        expect(data["key"]["1"].k).to eq("v")
      end
    end
    context "when given objects which have same class but different properties" do
      it "should raise ParseError" do
        expect {
          PHPSession::Decoder.decode('key|a:2:{s:1:"1";O:4:"Nyan":1:{s:1:"k";s:1:"v";}s:1:"2";O:4:"Nyan":0:{}}')
        }.to raise_error(PHPSession::Errors::ParseError)
      end
    end
    context "when given multi key session data" do
      it "should return a hash which has multipul keys" do
        expect(
          PHPSession::Decoder.decode('key1|d:3.1415;key2|s:4:"hoge";')
        ).to eq({
          "key1" => 3.1415,
          "key2" => "hoge",
        })
      end
    end
    context "when given nested array" do
      it "should return a nested array" do
        expect(
          PHPSession::Decoder.decode('key1|a:1:{s:1:"a";a:1:{s:1:"b";s:1:"c";}}')
        ).to eq({
          "key1" => {
            "a" => {
               "b" => "c"
            }
          }
        })
      end
    end
    context "when given a complex data" do
      it "should return a complex hash" do
        session_data = <<'EOS'
Config|a:3:{s:9:"userAgent";s:32:"d2673506d1c64ae55d1ea2421143f994";s:4:"time";i:1382414678;s:7:"timeout";i:10;}Account|a:2:{s:7:"Account";a:14:{s:2:"id";s:1:"1";s:7:"user_id";s:1:"1";s:5:"state";s:6:"active";s:5:"email";s:16:"test@example.com";s:8:"password";s:32:"5a2c1429a27a9783609e8b429748aa33";s:10:"owner_flag";b:1;s:4:"name";s:9:"テスト";s:7:"created";s:19:"2013-10-16 11:21:35";s:8:"modified";s:19:"2013-10-16 11:21:36";s:4:"uuid";s:36:"0e866700-c572-4d17-aab3-de0f35cf502e";s:10:"user_state";s:6:"active";s:8:"pc1_flag";b:0;s:10:"account_id";s:1:"1";s:8:"rmc_type";s:2:"pc";}s:4:"User";a:20:{s:2:"id";s:1:"1";s:12:"company_name";s:9:"テスト";s:13:"producer_name";s:9:"テスト";s:16:"consumer_message";s:0:"";s:7:"created";s:19:"2013-10-16 11:21:35";s:8:"modified";s:19:"2013-10-16 11:21:35";s:5:"state";s:6:"active";s:10:"apply_flag";b:0;s:9:"paid_flag";b:0;s:17:"company_name_kana";s:0:"";s:18:"producer_name_kana";s:0:"";s:15:"payer_name_kana";s:0:"";s:8:"zip_code";s:0:"";s:10:"prefecture";s:0:"";s:7:"address";s:0:"";s:8:"address2";s:0:"";s:5:"phone";s:0:"";s:5:"other";s:0:"";s:4:"uuid";s:36:"f6120e89-0554-449a-9c79-aa330ba9d6c5";s:8:"pc1_flag";b:0;}}Auth|a:0:{}
EOS
        expect(PHPSession::Decoder.decode(session_data)).to eq({
          "Config" => {
            "userAgent"=>"d2673506d1c64ae55d1ea2421143f994",
            "time"=>1382414678,
            "timeout"=>10
          },
          "Account" => {
            "Account"=> {
              "id"=>"1",
              "user_id"=>"1",
              "state"=>"active",
              "email"=>"test@example.com",
              "password"=>"5a2c1429a27a9783609e8b429748aa33",
              "owner_flag"=>true,
              "name"=>"テスト",
              "created"=>"2013-10-16 11:21:35",
              "modified"=>"2013-10-16 11:21:36",
              "uuid"=>"0e866700-c572-4d17-aab3-de0f35cf502e",
              "user_state"=>"active",
              "pc1_flag"=>false,
              "account_id"=>"1",
              "rmc_type"=>"pc",
            },
            "User"=> {
              "id"=>"1",
              "company_name"=>"テスト",
              "producer_name"=>"テスト",
              "consumer_message"=>"",
              "created"=>"2013-10-16 11:21:35",
              "modified"=>"2013-10-16 11:21:35",
              "state"=>"active",
              "apply_flag"=>false,
              "paid_flag"=>false,
              "company_name_kana"=>"",
              "producer_name_kana"=>"",
              "payer_name_kana"=>"",
              "zip_code"=>"",
              "prefecture"=>"",
              "address"=>"",
              "address2"=>"",
              "phone"=>"",
              "other"=>"",
              "uuid"=>"f6120e89-0554-449a-9c79-aa330ba9d6c5",
              "pc1_flag"=>false}
            },
          "Auth"=>{
          }
        })
      end
    end
  end
end
