# -*- coding: utf-8 -*-
require 'spec_helper'

describe PHPSession do
  describe "load" do
    context "when session file encoding is utf8" do
      before do
        @session_file = create_dummy_session_file('key|s:13:"テスト🍺";')
      end

      it "should be able to load file with internal:nil, external:utf8" do
        option = {
          :internal_encoding => nil,
          :external_encoding => "UTF-8",
        }
        session = PHPSession.new(@session_file[:dir_name], option)
        data = session.load(@session_file[:session_id])
        expect(data).to eq({"key" => "テスト🍺"})
      end

      it "should be able to load file with internal:utf8, external:utf8" do
        option = {
          :internal_encoding => "UTF-8",
          :external_encoding => "UTF-8",
        }
        session = PHPSession.new(@session_file[:dir_name], option)
        data = session.load(@session_file[:session_id])
        expect(data).to eq({"key" => "テスト🍺"})
      end

      it "should return euc-jp string with internal:euc-jp, exterenal:utf8" do
        option = {
          :internal_encoding => "EUC-JP",
          :external_encoding => "UTF-8",
          :encoding_option => {:undef => :replace}
        }
        session = PHPSession.new(@session_file[:dir_name], option)
        data = session.load(@session_file[:session_id])
        expect(data).to eq({"key" => "テスト🍺".encode("EUC-JP", {:undef => :replace})})
      end

      after do
        File.delete(@session_file[:file_path])
      end
    end

    context "when session file exists" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
      end

      it "should return session data" do
        session = PHPSession.new(@session_file[:dir_name])
        data = session.load(@session_file[:session_id])
        expect(data).to eq({"key" => "a"})
      end

      after do
        File.delete(@session_file[:file_path])
      end
    end

    context "when session file dosen't exist" do
      it "should return new session data" do
        session = PHPSession.new(Dir.tmpdir)
        data = session.load("session_id")
        expect(data).to eq({})
      end
    end
  end

  describe "#save" do
    before do
      @session_file = create_dummy_session_file('key|s:1:"a";')
    end

    it "should save session_data in session_file" do
      option = {
        :external_encoding => "EUC-JP",
        :internal_encoding => "UTF-8",
        :encoding_option   => {:undef => :replace}
      }
      session = PHPSession.new(@session_file[:dir_name], option)
      data = session.load(@session_file[:session_id])
      data["key"] = "テスト🍣"
      session.save(@session_file[:session_id], data)

      # read in bytesequence mode to avoid encoding conversion
      byte_sequence = IO.read(@session_file[:file_path], File.size(@session_file[:file_path]))
      expect(byte_sequence.force_encoding('EUC-JP')).to eq('key|s:7:"テスト?";'.encode("EUC-JP"))
    end

    after do
      File.delete(@session_file[:file_path])
    end
  end

  describe "#destroy" do
    context "when session file exists and loaded" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
      end

      it "should delete session file" do
        session = PHPSession.new(@session_file[:dir_name])
        session.destroy(@session_file[:session_id])
        expect(File.exists?(@session_file[:file_path])).to eq(false)
      end
    end
  end
end
