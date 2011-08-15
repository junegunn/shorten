# encoding: UTF-8

module Shorten
  BASE36 = ((0..9).to_a + ('a'..'z').to_a).map(&:to_s).join
  BASE62 = BASE36 + ('A'..'Z').map(&:to_s).join

  module Numeric
    # @param [String] chars Sequence of characters for shortening
    # @return [String] Shortened string
    def shorten chars = Shorten::BASE62
      raise ArgumentError.new('String required') unless chars.is_a? String
      raise ArgumentError.new('Only non-negative integers can be shortened') if self < 0

      num = self
      len = chars.length
      str = ''
      while num > 0
        mod = num % len
        str = chars[mod, 1] + str
        num /= len
      end
      str
    end
  end

  module String
    # @param [String] chars Sequence of characters for unshortening
    # @return [Fixnum/Bignum] Unshortened number
    def unshorten chars = Shorten::BASE62
      raise ArgumentError.new('String required') unless chars.is_a? String

      num = 0
      len = chars.length
      self.each_char do |c|
        num *= len
        char = chars.index(c)
        raise ArgumentError.new('Cannot unshorten: invalid characters') if char.nil?
        num += char
      end
      num
    end
  end
end

class Fixnum
  include Shorten::Numeric
end

class Bignum
  include Shorten::Numeric
end

class String
  include Shorten::String
end

