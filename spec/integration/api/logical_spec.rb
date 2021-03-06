require "spec_helper"

module Vault
  describe Logical do
    subject { vault_test_client.logical }

    describe "#list" do
      it "returns the empty array when no items exist" do
        expect(subject.list("secret/that/never/existed")).to eq([])
      end

      it "returns all secrets" do
        subject.write("secret/test-list-1", foo: "bar")
        subject.write("secret/test-list-2", foo: "bar")
        secrets = subject.list("secret")
        expect(secrets).to be_a(Array)
        expect(secrets).to include("test-list-1")
        expect(secrets).to include("test-list-2")
      end
    end

    describe "#read" do
      it "returns nil with the thing does not exist" do
        expect(subject.read("secret/foo/bar/zip")).to be(nil)
      end

      it "returns the secret when it exists" do
        subject.write("secret/test-read", foo: "bar")
        secret = subject.read("secret/test-read")
        expect(secret).to be
        expect(secret.data).to eq(foo: "bar")
      end

      it "returns the secret when it exists and is specified via prefix" do
        subject.write("secret/test-read", foo: "bar")
        secret = subject.read("test-read", :path_prefix => "secret")
        expect(secret).to be
        expect(secret.data).to eq(foo: "bar")
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-read", foo: "bar")
        secret = subject.read("secret/b:@c%n-read")
        expect(secret).to be
        expect(secret.data).to eq(foo: "bar")
      end
    end

    describe "#write" do
      it "creates and returns the secret" do
        subject.write("secret/test-write", zip: "zap")
        result = subject.read("secret/test-write")
        expect(result).to be
        expect(result.data).to eq(zip: "zap")
      end

      it "overwrites existing secrets" do
        subject.write("secret/test-overwrite", zip: "zap")
        subject.write("secret/test-overwrite", bacon: true)
        result = subject.read("secret/test-overwrite")
        expect(result).to be
        expect(result.data).to eq(bacon: true)
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-write", foo: "bar")
        subject.write("secret/b:@c%n-write", bacon: true)
        secret = subject.read("secret/b:@c%n-write")
        expect(secret).to be
        expect(secret.data).to eq(bacon: true)
      end
    end

    describe "#delete" do
      it "deletes the secret" do
        subject.write("secret/delete", foo: "bar")
        expect(subject.delete("secret/delete")).to be(true)
        expect(subject.read("secret/delete")).to be(nil)
      end

      it "allows special characters" do
        subject.write("secret/b:@c%n-delete", foo: "bar")
        expect(subject.delete("secret/b:@c%n-delete")).to be(true)
        expect(subject.read("secret/b:@c%n-delete")).to be(nil)
      end

      it "does not error if the secret does not exist" do
        expect {
          subject.delete("secret/delete")
          subject.delete("secret/delete")
          subject.delete("secret/delete")
        }.to_not raise_error
      end
    end
  end
end
