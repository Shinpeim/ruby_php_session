# -*- coding: utf-8 -*-
require 'spec_helper'

describe PHPSession do
  describe "load" do
    context "when session file exists" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
      end

      it "should return session data" do
        session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
        begin
          data = session.load
          expect(data).to eq({"key" => "a"})
        ensure
          session.ensure_file_closed
        end
      end

      after do
        File.delete(@session_file[:file_path])
      end
    end

    context "when session file dosen't exist" do
      it "should return new session data" do
        session = PHPSession.new(Dir.tmpdir,"session_id")
        begin
          data = session.load
          expect(data).to eq({})
        ensure
          session.ensure_file_closed
        end
      end
    end
  end

  describe "#commit" do
    before do
      @session_file = create_dummy_session_file('key|s:1:"a";')
    end

    it "should save session_data in session_file" do
      session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
      data = session.load
      data["key"] = "b"
      session.commit(data)

      expect(IO.read(@session_file[:file_path])).to eq('key|s:1:"b";')
    end

    after do
      File.delete(@session_file[:file_path])
    end
  end

  describe "#destroy" do
    context "when session file exists and loaded" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
        @session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
        @session.load
      end

      it "should delete session file" do
        @session.destroy
        expect(File.exists?(@session_file[:file_path])).to eq(false)
      end
    end

    context "when session file exists and not loaded" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
        @session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
      end

      it "should delete session file" do
        @session.destroy
        expect(File.exists?(@session_file[:file_path])).to eq(false)
      end
    end
  end
end
