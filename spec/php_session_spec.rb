require 'spec_helper'

describe PHPSession do
  describe "#[]" do
    context "when session file exists" do
      before do
        @session_file = create_dummy_session_file('key|s:1:"a";')
      end
      it "should return session data" do
        session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
        expect(session["key"]).to eq("a")

        session.ensure_file_closed
      end

      after do
        File.delete(@session_file[:file_path])
      end
    end
    context "when session file dosen't exist" do
      it "should return nil" do
        session = PHPSession.new(Dir.tmpdir,"session_id")
        expect(session["key"]).to eq(nil)
      end
    end
  end

  describe "#commit" do
    before do
      @session_file = create_dummy_session_file('key|s:1:"a";')
    end

    it "should save session_data in session_file" do
      session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
      session["key"] = "b"
      session.commit

      expect(IO.read(@session_file[:file_path])).to eq('key|s:1:"b";')
    end

    after do
      File.delete(@session_file[:file_path])
    end
  end

  describe "#destroy" do
    before do
      @session_file = create_dummy_session_file('key|s:1:"a";')
    end

    it "should resete session data" do
      session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
      session.destroy

      expect(session["key"]).to eq(nil)
    end

    it "should delete session file" do
      session = PHPSession.new(@session_file[:dir_name], @session_file[:session_id])
      session.destroy

      expect(File.exists?(@session_file[:file_path])).to eq(false)
    end
  end
end
