#!/usr/bin/env rspec
# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

CHEETSHEET = {
  :base62 => {
    1 => '1',
    9 => '9',
    10 => 'a',
    36 => 'A',
    37 => 'B',
    62 => '10',
    63 => '11',
    100000000000000000000000000000000 => 'xPEhw0uJHtT7g9cK7C'
  },
  :base36 => {
    1 => '1',
    9 => '9',
    10 => 'a',
    36 => '10',
    37 => '11'
  }
}

describe "Shorten" do
  it "shortens a number" do
    CHEETSHEET[:base62].each do |k, v|
      k.shorten.should eq v
      k.shorten(Shorten::BASE62).should eq v
    end

    CHEETSHEET[:base36].each do |k, v|
      k.shorten(Shorten::BASE36).should eq v
      k.shorten(Shorten::BASE36).should eq k.to_s(36)
    end

    (1..10000).each do |i|
      i.shorten.unshorten.should eq i
    end

    (9999999999999999999989999..9999999999999999999999999).each do |i|
      i.shorten.unshorten.should eq i
    end
  end

  it "shortens a number with any given characters" do
    chars = Shorten::BASE62
    my_chars = chars.each_char.to_a.shuffle.join
    map = {}

    chars.each_char.each_with_index do |e, idx|
      map[e] = my_chars[idx]
    end

    CHEETSHEET[:base62].each do |k, v|
      k.shorten(my_chars).should eq(v.each_char.map { |e| map[e] }.join)
      k.shorten(my_chars).unshorten(my_chars).should eq(k)
    end

    12345.shorten("ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ").should eq "ㅁㅅㅎㅌ"
    "ㅁㅅㅎㅌ".unshorten("ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ").should eq 12345
  end

  it "shortens Bignums" do
    bn = 1000000000000000000000000000000000
    bn.shorten(Shorten::BASE36).should eq bn.to_s(36)
  end

  it "unshortens a shortened number" do
    CHEETSHEET[:base62].each do |k, v|
      k.shorten.unshorten.should eq k
      k.shorten(Shorten::BASE62).unshorten(Shorten::BASE62).should eq k
    end

    CHEETSHEET[:base36].each do |k, v|
      k.shorten(Shorten::BASE36).unshorten(Shorten::BASE36).should eq k
      k.shorten(Shorten::BASE36).unshorten(Shorten::BASE36).should eq k
    end
  end

  it "throws error on unshorten-able string" do
    expect { "-_-;".unshorten }.to raise_error(ArgumentError)
  end

  it "cannot shorten negative integers" do
    expect { -5.shorten }.to raise_error(ArgumentError)
  end

  it "does not support Float" do
    expect { 8.27.shorten }.to raise_error(NoMethodError)
  end

  it "throws error on invalid parameter" do
    [
      1234,
      'a'..'z',
      {:a => 1},
      ["hello"]
    ].each do |inv|
      expect { 1234.shorten(inv) }.to raise_error(ArgumentError)
      expect { "1234".unshorten(inv) }.to raise_error(ArgumentError)
    end
  end
end
